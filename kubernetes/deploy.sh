#!/bin/bash

# Vérifier si Minikube est en cours d'exécution
echo "Vérification de l'état de Minikube..."
if ! minikube status | grep -q "Running"; then
  echo "Minikube n'est pas en cours d'exécution. Démarrage de Minikube..."
  minikube start
else
  echo "Minikube est déjà en cours d'exécution."
fi

# Activer l'addon Ingress si ce n'est pas déjà fait
echo "Activation de l'addon Ingress..."
minikube addons enable ingress

# Créer le namespace
echo "Création du namespace odc-project..."
kubectl apply -f namespace.yaml

# Déployer les secrets
echo "Déploiement des secrets..."
kubectl apply -f postgres-secret.yaml

# Déployer le PVC pour PostgreSQL
echo "Déploiement du PersistentVolumeClaim pour PostgreSQL..."
kubectl apply -f postgres-pvc.yaml

# Déployer PostgreSQL
echo "Déploiement de PostgreSQL..."
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml

# Attendre que PostgreSQL soit prêt
echo "Attente que PostgreSQL soit prêt..."
kubectl wait --namespace=odc-project --for=condition=ready pod -l app=postgres --timeout=120s

# Déployer le backend
echo "Déploiement du backend..."
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

# Déployer le frontend
echo "Déploiement du frontend..."
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# Déployer l'Ingress
echo "Déploiement de l'Ingress..."
kubectl apply -f ingress.yaml

# Afficher les informations sur les pods
echo "Pods déployés:"
kubectl get pods -n odc-project

# Afficher les informations sur les services
echo "Services déployés:"
kubectl get services -n odc-project

# Afficher les informations sur l'Ingress
echo "Ingress déployé:"
kubectl get ingress -n odc-project

# Afficher l'URL pour accéder à l'application
echo "Pour accéder à l'application, ajoutez l'entrée suivante à votre fichier /etc/hosts:"
echo "$(minikube ip) odc.local"
echo "Puis accédez à l'application via: http://odc.local"
