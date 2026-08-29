# Virtual Job Simulation Platform — DevOps Deployment Project

## Week 1 — DevOps Assistant

A small containerized virtual job simulation platform created to demonstrate the Week 1 deployment strategy using Docker and Kubernetes.

## Architecture

User → Frontend → Backend API → Database

The project includes:
- Docker containerization
- Docker Compose for local multi-container testing
- Kubernetes Deployment and Service manifests
- ConfigMap and Secret examples
- Health endpoint
- Kubernetes readiness and liveness probes
- PersistentVolumeClaim example
- Basic network policy
- CI workflow for building/testing the backend
- Troubleshooting and deployment documentation

## Project Structure

```text
virtual-job-simulation-devops/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .dockerignore
├── frontend/
│   ├── index.html
│   ├── style.css
│   ├── Dockerfile
│   └── nginx.conf
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── backend-deployment.yaml
│   ├── backend-service.yaml
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   ├── database.yaml
│   ├── network-policy.yaml
│   └── ingress.yaml
├── docker-compose.yml
└── .github/workflows/ci.yml
```

## Run locally with Docker Compose

```bash
docker compose up --build
```

Open:
- Frontend: http://localhost:8080
- Backend health: http://localhost:5000/health
- Backend jobs: http://localhost:5000/api/jobs

Stop:
```bash
docker compose down
```

## Run with Kubernetes

Build the images first:

```bash
docker build -t virtual-job-backend:1.0 ./backend
docker build -t virtual-job-frontend:1.0 ./frontend
```

For Minikube:

```bash
minikube image load virtual-job-backend:1.0
minikube image load virtual-job-frontend:1.0
kubectl apply -f k8s/
kubectl get pods
kubectl get services
```

For a remote cluster, push the images to a container registry and replace the image names in the Kubernetes Deployment files.

## Health checks

The backend provides:

```text
GET /health
```

Expected response:

```json
{"status":"healthy","service":"virtual-job-api"}
```

## Security notes

The Secret manifest contains placeholder values only. Real credentials must never be committed to Git. In a production environment, use a proper secret-management solution and restrict Kubernetes RBAC permissions.

## Week 1 deliverable mapping

| Internship requirement | Project evidence |
|---|---|
| Containerization | Dockerfiles + Docker Compose |
| Container image creation | Docker build instructions |
| Orchestration | Kubernetes Deployments/Services |
| Network configuration | Services, Ingress and NetworkPolicy |
| Testing | Health endpoint + CI workflow |
| Risk management | README security/recovery notes |
| Troubleshooting | README commands and Kubernetes manifests |
| Backup strategy | Persistent storage and backup section |

## Backup strategy

For a production database, schedule database-aware backups and store them outside the cluster. Test restoration periodically. The Kubernetes PVC in this project demonstrates persistent storage; it is not itself a complete backup solution.

## Rollback

```bash
kubectl rollout history deployment/virtual-job-backend
kubectl rollout undo deployment/virtual-job-backend
kubectl rollout status deployment/virtual-job-backend
```

## Author

Saniya Prakash Korgaonkar  
DevOps Assistant — YuvaIntern  
Week 1 Task
