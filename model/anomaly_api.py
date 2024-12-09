from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)

# Load the trained model
model_path = "trained_model.pkl"  # Ensure the path matches where your model is saved
model = joblib.load(model_path)

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Parse incoming JSON request
        data = request.json
        temperature = data.get('temperature')

        # Ensure temperature is provided
        if temperature is None:
            return jsonify({'error': 'Temperature value is required'}), 400

        # Reshape input and make prediction
        prediction = model.predict(np.array([[temperature]]))
        is_anomaly = int(prediction[0] == -1)  # -1 indicates an anomaly

        # Return prediction
        return jsonify({'temperature': temperature, 'is_anomaly': is_anomaly})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)  # Run Flask app on port 5000