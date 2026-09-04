import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from app import app


def test_root():
    client = app.test_client()
    response = client.get("/")

    assert response.status_code == 200
    data = response.get_json()

    assert data["message"] == "Virtual Job Simulation API is running"


def test_health():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    data = response.get_json()

    assert data["status"] == "healthy"
    assert data["service"] == "virtual-job-api"


def test_jobs():
    client = app.test_client()
    response = client.get("/api/jobs")

    assert response.status_code == 200
    data = response.get_json()

    assert data["platform"] == "Virtual Job Simulation Platform"
    assert len(data["jobs"]) == 3
    assert data["jobs"][0]["title"] == "Cloud Support Intern"
