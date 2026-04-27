import os
from flask import Flask, send_from_directory

FRONTEND = os.path.join(os.path.dirname(__file__), '..', 'frontend')

app = Flask(__name__, static_folder=FRONTEND, static_url_path='')

@app.route('/')
def index():
    return send_from_directory(FRONTEND, 'index.html')

if __name__ == '__main__':
    app.run(debug=True)
