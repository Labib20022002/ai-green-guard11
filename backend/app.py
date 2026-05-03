from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
import numpy as np
import tensorflow as tf

app = Flask(__name__)
CORS(app)

# ==========================================
# LOAD LEAF DETECTOR MODEL (.tflite)
# ==========================================

leaf_interpreter = tf.lite.Interpreter(
    model_path="leaf_detector.tflite"
)

leaf_interpreter.allocate_tensors()

leaf_input_details = leaf_interpreter.get_input_details()
leaf_output_details = leaf_interpreter.get_output_details()

# ==========================================
# LOAD DISEASE DETECTOR MODEL (.tflite)
# ==========================================

disease_interpreter = tf.lite.Interpreter(
    model_path="mobilenetv2.tflite"
)

disease_interpreter.allocate_tensors()

disease_input_details = disease_interpreter.get_input_details()
disease_output_details = disease_interpreter.get_output_details()

# ==========================================
# LOAD LABELS
# ==========================================

with open("disease_level.txt", "r") as f:
    disease_labels = [line.strip() for line in f.readlines()]

with open("leaf_level.txt", "r") as f:
    leaf_labels = [line.strip() for line in f.readlines()]

# ==========================================
# IMAGE SIZE
# ==========================================

IMG_SIZE = 224

# ==========================================
# PREPROCESS IMAGE
# ==========================================

def preprocess_image(image):

    image = image.resize((IMG_SIZE, IMG_SIZE))

    image = np.array(image).astype(np.float32)

    image = image / 255.0

    image = np.expand_dims(image, axis=0)

    return image

# ==========================================
# LEAF DETECTION FUNCTION
# ==========================================

def detect_leaf(image_array):

    leaf_interpreter.set_tensor(
        leaf_input_details[0]['index'],
        image_array
    )

    leaf_interpreter.invoke()

    prediction = leaf_interpreter.get_tensor(
        leaf_output_details[0]['index']
    )

    predicted_index = int(np.argmax(prediction))

    confidence = float(np.max(prediction))

    label = leaf_labels[predicted_index]

    return label, confidence

# ==========================================
# DISEASE DETECTION FUNCTION
# ==========================================

def detect_disease(image_array):

    disease_interpreter.set_tensor(
        disease_input_details[0]['index'],
        image_array
    )

    disease_interpreter.invoke()

    prediction = disease_interpreter.get_tensor(
        disease_output_details[0]['index']
    )

    predicted_index = int(np.argmax(prediction))

    confidence = float(np.max(prediction))

    disease_name = disease_labels[predicted_index]

    return disease_name, confidence

# ==========================================
# MAIN PREDICTION ROUTE
# ==========================================

@app.route('/')
def home():

    return jsonify({
        'message': 'AI-GreenGuard Backend Running Successfully'
    })

@app.route('/predict', methods=['POST'])
def predict():

    try:

        # ==========================================
        # CHECK FILE
        # ==========================================

        if 'file' not in request.files:

            return jsonify({
                'error': 'No image uploaded'
            })

        file = request.files['file']

        # ==========================================
        # OPEN IMAGE
        # ==========================================

        image = Image.open(file).convert('RGB')

        processed_image = preprocess_image(image)

        # ==========================================
        # LEAF DETECTION
        # ==========================================

        leaf_label, leaf_confidence = detect_leaf(
            processed_image
        )

        print("Leaf Prediction:", leaf_label)
        print("Leaf Confidence:", leaf_confidence)

        # ==========================================
        # CHECK IF IMAGE IS LEAF
        # ==========================================

        # IMPORTANT:
        # Adjust this according to your labels
        # Example:
        # if label is "leaf"

        if leaf_label.lower() != "leaf":

            return jsonify({
                'error': 'Please upload a valid leaf image',
                'prediction': leaf_label,
                'confidence': round(leaf_confidence * 100, 2)
            })

        # ==========================================
        # DISEASE DETECTION
        # ==========================================

        disease_name, disease_confidence = detect_disease(
            processed_image
        )

        print("Disease:", disease_name)
        print("Confidence:", disease_confidence)

        # ==========================================
        # RETURN RESULT
        # ==========================================

        return jsonify({

            'success': True,

            'disease': disease_name,

            'confidence': round(
                disease_confidence * 100,
                2
            )

        })

    except Exception as e:

        return jsonify({
            'error': str(e)
        })

# ==========================================
# RUN SERVER
# ==========================================

if __name__ == '__main__':

    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )

