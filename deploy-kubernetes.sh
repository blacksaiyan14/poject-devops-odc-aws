#!/bin/bash

echo "Starting Kubernetes deployment..."

# Ensure Minikube is running
minikube status || minikube start

# Apply Kubernetes manifests
echo "Deploying PostgreSQL database..."
kubectl apply -f manifests/database/postgres-secret.yml
kubectl apply -f manifests/database/postgres-pvc.yml
kubectl apply -f manifests/database/deployment.yml

# Wait for database to be ready
echo "Waiting for database to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres

# Deploy backend and frontend
echo "Deploying backend application..."
kubectl apply -f manifests/backend/deployment.yml

echo "Deploying frontend application..."
kubectl apply -f manifests/frontend/deployment.yml

# Deploy Ingress
echo "Deploying Ingress..."
kubectl apply -f manifests/ingress/ingress.yml

# Get Ingress status
echo "Ingress deployed, checking status..."
kubectl get ingress odc-ingress

# Update /etc/hosts for local access
MINIKUBE_IP=$(minikube ip)

# Check if odc.local is already in /etc/hosts
if grep -q "odc.local" /etc/hosts; then
    echo "odc.local already in /etc/hosts, updating if needed"
    sudo sed -i "s/.*odc.local/$MINIKUBE_IP odc.local/" /etc/hosts
else
    echo "Adding odc.local to /etc/hosts"
    echo "$MINIKUBE_IP odc.local" | sudo tee -a /etc/hosts
fi

echo "======================================================"
echo "✅ Deployment completed successfully!"
echo "You can now access the application at http://odc.local"
echo "======================================================"
