#!/usr/bin/env bash

set -Eeuo pipefail

NAMESPACE="virtual-job-platform"
BACKEND_DEPLOYMENT="virtual-job-backend"
FRONTEND_DEPLOYMENT="virtual-job-frontend"

REGISTRY="ghcr.io/korgaonkarsaniya-cpu/virtual-job-simulation-cicd-pj4"
IMAGE_TAG="${1:-latest}"

BACKEND_IMAGE="${REGISTRY}/backend:${IMAGE_TAG}"
FRONTEND_IMAGE="${REGISTRY}/frontend:${IMAGE_TAG}"

OLD_BACKEND_IMAGE=""
OLD_FRONTEND_IMAGE=""
PORT_FORWARD_PID=""

echo "=========================================="
echo " Virtual Job Simulation Deployment"
echo "=========================================="
echo "Backend image : ${BACKEND_IMAGE}"
echo "Frontend image: ${FRONTEND_IMAGE}"
echo

cleanup() {
    if [[ -n "${PORT_FORWARD_PID}" ]]; then
        kill "${PORT_FORWARD_PID}" 2>/dev/null || true
    fi
}

rollback() {
    echo
    echo "=========================================="
    echo " Deployment failed - Starting rollback"
    echo "=========================================="

    if [[ -n "${OLD_BACKEND_IMAGE}" ]]; then
        kubectl set image deployment/"${BACKEND_DEPLOYMENT}" \
            backend="${OLD_BACKEND_IMAGE}" \
            -n "${NAMESPACE}" || true
    fi

    if [[ -n "${OLD_FRONTEND_IMAGE}" ]]; then
        kubectl set image deployment/"${FRONTEND_DEPLOYMENT}" \
            frontend="${OLD_FRONTEND_IMAGE}" \
            -n "${NAMESPACE}" || true
    fi

    kubectl rollout status deployment/"${BACKEND_DEPLOYMENT}" \
        -n "${NAMESPACE}" \
        --timeout=120s || true

    kubectl rollout status deployment/"${FRONTEND_DEPLOYMENT}" \
        -n "${NAMESPACE}" \
        --timeout=120s || true

    echo
    echo "Rollback completed."
}

on_error() {
    local exit_code=$?
    rollback
    cleanup
    exit "${exit_code}"
}

trap on_error ERR
trap cleanup EXIT

echo "Checking Kubernetes connection..."
kubectl cluster-info

echo
echo "Saving current image versions for rollback..."

OLD_BACKEND_IMAGE=$(kubectl get deployment "${BACKEND_DEPLOYMENT}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.spec.template.spec.containers[0].image}')

OLD_FRONTEND_IMAGE=$(kubectl get deployment "${FRONTEND_DEPLOYMENT}" \
    -n "${NAMESPACE}" \
    -o jsonpath='{.spec.template.spec.containers[0].image}')

echo "Previous backend image : ${OLD_BACKEND_IMAGE}"
echo "Previous frontend image: ${OLD_FRONTEND_IMAGE}"

echo
echo "Updating backend deployment..."

kubectl set image deployment/"${BACKEND_DEPLOYMENT}" \
    backend="${BACKEND_IMAGE}" \
    -n "${NAMESPACE}"

echo
echo "Updating frontend deployment..."

kubectl set image deployment/"${FRONTEND_DEPLOYMENT}" \
    frontend="${FRONTEND_IMAGE}" \
    -n "${NAMESPACE}"

echo
echo "Waiting for backend rollout..."

kubectl rollout status deployment/"${BACKEND_DEPLOYMENT}" \
    -n "${NAMESPACE}" \
    --timeout=120s

echo
echo "Waiting for frontend rollout..."

kubectl rollout status deployment/"${FRONTEND_DEPLOYMENT}" \
    -n "${NAMESPACE}" \
    --timeout=120s

echo
echo "Checking deployed pods..."

kubectl get pods -n "${NAMESPACE}"

echo
echo "Checking backend health endpoint..."

kubectl port-forward \
    -n "${NAMESPACE}" \
    service/virtual-job-backend 5001:5000 \
    > /tmp/backend-port-forward.log 2>&1 &

PORT_FORWARD_PID=$!

sleep 5

curl --fail --silent http://127.0.0.1:5001/health

echo
echo
echo "=========================================="
echo " Deployment successful!"
echo "=========================================="
