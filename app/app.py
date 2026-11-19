from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    return(
        f"<h1>Deployed via Mohammad Maaz Full CI/CD Pipeline!</h1><p>Version: {os.getenv('APP_VERSION', 'unknown')}</p><p>Host: {socket.gethostname()}</p>"
        f"<p>Version: {os.getenv('APP_VERSION', 'unknown')}</p>"
        f"<p>Color: {os.getenv('DEPLOY_COLOR', 'unknown')}</p>"
        f"<p>Host: {socket.gethostname()}</p>"
    )

@app.route('/health')
def health():
    return {"status": "healthy"}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
