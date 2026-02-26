import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Interpreter? _leafInterpreter;
  Interpreter? _diseaseInterpreter;

  List<String> leafLabels = [];
  List<String> diseaseLabels = [];

  File? _image;
  String _result = '';
  bool _loading = false;

  static const int imgSize = 224;

  // Thresholds
  static const double leafThreshold = 0.80;
  static const double diseaseThreshold = 0.60;

  @override
  void initState() {
    super.initState();
    _loadModels();
    _loadLabels();
  }

  // ================= LOAD MODELS =================
  Future<void> _loadModels() async {
    _leafInterpreter =
        await Interpreter.fromAsset('assets/model/leaf_detector.tflite');
    _diseaseInterpreter =
        await Interpreter.fromAsset('assets/model/mobilenetv2.tflite');
  }

  // ================= LOAD LABELS =================
  Future<void> _loadLabels() async {
    leafLabels = (await DefaultAssetBundle.of(context)
            .loadString('assets/labels/leaf_labels.txt'))
        .split('\n');

    diseaseLabels = (await DefaultAssetBundle.of(context)
            .loadString('assets/labels/disease_labels.txt'))
        .split('\n');
  }

  // ================= IMAGE PICKER =================
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _result = '';
    });

    await _runPipeline();
  }

  // ================= PREPROCESS =================
  Float32List preprocess(img.Image image) {
    final Float32List input = Float32List(imgSize * imgSize * 3);
    int index = 0;

    for (int y = 0; y < imgSize; y++) {
      for (int x = 0; x < imgSize; x++) {
        final pixel = image.getPixel(x, y);
        input[index++] = pixel.r / 127.5 - 1.0;
        input[index++] = pixel.g / 127.5 - 1.0;
        input[index++] = pixel.b / 127.5 - 1.0;
      }
    }
    return input;
  }

  // ================= RUN PIPELINE =================
  Future<void> _runPipeline() async {
    if (_image == null) return;
    setState(() => _loading = true);

    final imageBytes = await _image!.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return;

    final resized =
        img.copyResize(image, width: imgSize, height: imgSize);

    final input =
        preprocess(resized).reshape([1, imgSize, imgSize, 3]);

    // ---------- STAGE 1: LEAF DETECTOR ----------
    final leafOutput = List.generate(1, (_) => List.filled(2, 0.0));
    _leafInterpreter!.run(input, leafOutput);

    final leafConfidence = leafOutput[0][0]; // leaf index = 0

    if (leafConfidence < leafThreshold) {
      setState(() {
        _result = '❌ Not a leaf image\nPlease capture a clear leaf photo.';
        _loading = false;
      });
      return;
    }

    // ---------- STAGE 2: DISEASE CLASSIFIER ----------
    final diseaseOutput =
        List.generate(1, (_) => List.filled(diseaseLabels.length, 0.0));
    _diseaseInterpreter!.run(input, diseaseOutput);

    int bestIndex = 0;
    double bestScore = 0;

    for (int i = 0; i < diseaseLabels.length; i++) {
      if (diseaseOutput[0][i] > bestScore) {
        bestScore = diseaseOutput[0][i];
        bestIndex = i;
      }
    }

    if (bestScore < diseaseThreshold) {
      _result = '⚠ Uncertain disease\nTry another image';
    } else {
      _result =
          '${diseaseLabels[bestIndex]} (${(bestScore * 100).toStringAsFixed(2)}%)';
    }

    setState(() => _loading = false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI-GreenGuard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 250)
                : const Icon(Icons.eco, size: 200),

            const SizedBox(height: 20),

            _loading
                ? const CircularProgressIndicator()
                : Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}