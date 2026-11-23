from flask import Flask, jsonify
import time
import os

app = Flask(__name__)

START_TIME = time.time()
REQUEST_COUNT = 0

@app.before_request
def count_requests():
    global REQUEST_COUNT
    REQUEST_COUNT += 1

@app.route("/")
def home():
    return jsonify({
        "application": "AWS Self-Healing Infrastructure",
        "service": "demo-app",
        "version": "1.0",
        "status": "running"
    })

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "demo-app",
        "timestamp": time.time()
    }), 200

@app.route("/metrics")
def metrics():
    return jsonify({
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "request_count": REQUEST_COUNT,
        "process_id": os.getpid()
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
