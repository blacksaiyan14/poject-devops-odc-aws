#!/bin/bash

# Attendre que la base de données soit prête
echo "Attente de la base de données..."
sleep 5

# Appliquer les migrations
echo "Application des migrations..."
python manage.py migrate

# Démarrer Gunicorn
echo "Démarrage de l'application..."
exec gunicorn --bind 0.0.0.0:8000 odc.wsgi:application
