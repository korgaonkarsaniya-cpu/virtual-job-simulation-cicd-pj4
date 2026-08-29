from flask import Flask, jsonify
import os

app = Flask(__name__)

JOBS = [
    {
        "id": 1,
        "title": "Cloud Support Intern",
        "skills": ["Linux", "AWS", "Networking"]
    },
    {
        "id": 2,
        "title": "DevOps Intern",
        "skills": ["Docker", "Kubernetes", "CI/CD"]
    },
    {
        "id": 3,
        "title": "Software Testing Intern",
        "skills": ["Python", "Testing", "Git"]
    }
]

@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "virtual-job-api"
    })

@app.get("/api/jobs")
def jobs():
    return jsonify({
        "platform": "Virtual Job Simulation Platform",
        "jobs": JOBS
    })

@app.get("/")
def root():
    return jsonify({
        "message": "Virtual Job Simulation API is running"
    })

if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
