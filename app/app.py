from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    return f"<h1>Deployed by Mohammad Maaz via Full CI/CD Pipeline!</h1><p>Version: {os.getenv('APP_VERSION', 'unknown')}</p><p>Host: {socket.gethostname()}</p>"

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
