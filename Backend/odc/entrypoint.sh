#!/bin/bash

# Attendre que la base de données soit prête
echo "Attente de la base de données..."

# Attendre que la base de données soit disponible
for i in {1..30}; do
  echo "Tentative de connexion à la base de données... $i/30"
  python -c "import psycopg2; psycopg2.connect(dbname='odcdb', user='odc', password='odc123', host='database_container', port='5432')" && break
  sleep 2
done

echo "Base de données prête !"

# Appliquer les migrations
echo "Application des migrations..."
python manage.py migrate

# Démarrer Gunicorn
echo "Démarrage de l'application..."
exec gunicorn --bind 0.0.0.0:8000 odc.wsgi:application
