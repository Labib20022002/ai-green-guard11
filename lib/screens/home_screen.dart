import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  XFile? _image;

  String _result = '';

  bool _loading = false;

  // ==========================================
  // IMAGE PICKER
  // ==========================================

  Future<void> _pickImage(
      ImageSource source) async {

    final picker = ImagePicker();

    final picked =
        await picker.pickImage(
      source: source,
    );

    if (picked == null) return;

    setState(() {

      _image = picked;

      _result = '';

    });

    await predictDisease(picked);
  }

  // ==========================================
  // SEND IMAGE TO FLASK BACKEND
  // ==========================================

  Future<void> predictDisease(
      XFile imageFile) async {

    setState(() {

      _loading = true;

    });

    try {

      // ==========================================
      // BACKEND URL
      // ==========================================

      var request = http.MultipartRequest(

        'POST',

        Uri.parse(
          'http://127.0.0.1:5000/predict',
        ),

      );

      // ==========================================
      // READ IMAGE BYTES
      // ==========================================

      var bytes =
          await imageFile.readAsBytes();

      // ==========================================
      // CREATE MULTIPART FILE
      // ==========================================

      var multipartFile =
          http.MultipartFile.fromBytes(

        'file',

        bytes,

        filename: imageFile.name,

      );

      request.files.add(multipartFile);

      // ==========================================
      // SEND REQUEST
      // ==========================================

      var response =
          await request.send();

      // ==========================================
      // GET RESPONSE
      // ==========================================

      var responseString =
          await response.stream
              .bytesToString();

      var jsonData =
          jsonDecode(responseString);

      print(jsonData);

      // ==========================================
      // SUCCESS
      // ==========================================

      if (jsonData['success'] == true) {

        setState(() {

          _result =
              '${jsonData['disease']} '
              '(${jsonData['confidence']}%)';

        });

      }

      // ==========================================
      // ERROR
      // ==========================================

      else {

        setState(() {

          _result =
              jsonData['error'];

        });

      }

    } catch (e) {

      setState(() {

        _result = 'Error: $e';

      });

    }

    setState(() {

      _loading = false;

    });
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'AI-GreenGuard',
        ),

      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            // ==========================================
            // IMAGE DISPLAY
            // ==========================================

            _image != null

                ? Image.network(

                    _image!.path,

                    height: 250,

                  )

                : const Icon(

                    Icons.eco,

                    size: 200,

                  ),

            const SizedBox(height: 20),

            // ==========================================
            // RESULT
            // ==========================================

            _loading

                ? const CircularProgressIndicator()

                : Text(

                    _result,

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

            const SizedBox(height: 30),

            // ==========================================
            // BUTTONS
            // ==========================================

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,

              children: [

                ElevatedButton.icon(

                  icon: const Icon(
                    Icons.photo,
                  ),

                  label: const Text(
                    "Gallery",
                  ),

                  onPressed: () {

                    _pickImage(
                      ImageSource.gallery,
                    );

                  },

                ),

                ElevatedButton.icon(

                  icon: const Icon(
                    Icons.camera,
                  ),

                  label: const Text(
                    "Camera",
                  ),

                  onPressed: () {

                    _pickImage(
                      ImageSource.camera,
                    );

                  },

                ),

              ],

            ),

          ],

        ),

      ),

    );
  }
}

