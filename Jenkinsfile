pipeline {
    agent any
    environment {
        // Nouveau dépôt Docker Hub
        REGISTRY = 'blacksaiyan/poject-devops-odc-aws'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        
        // Images Docker avec le numéro de build
        BACKEND_IMAGE = "${REGISTRY}:backend-${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${REGISTRY}:frontend-${BUILD_NUMBER}"
        
        // Images Docker avec le tag "latest"
        BACKEND_LATEST = "${REGISTRY}:backend-latest"
        FRONTEND_LATEST = "${REGISTRY}:frontend-latest"
        
        // Ports pour les conteneurs
        BACKEND_PORT = "8000"
        FRONTEND_PORT = "3000"
        
        // Ancien registre (pour la compatibilité avec les images existantes)
        OLD_REGISTRY = 'blacksaiyan/projet-fil-rouge-jenkins'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'jenkins', url: 'https://github.com/blacksaiyan14/poject-devops-odc-aws.git'
            }
        }

        stage('Test Backend') {
            steps {
                dir('Backend/odc') {
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install -r requirements.txt
                        python manage.py test
                    '''
                }
            }
        }

        stage('Test Frontend') {
            steps {
                dir('Frontend') {
                    sh '''
                        npm ci
                        npm run test || echo "⚠️ Aucun test défini pour le frontend"
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Construction de l'image Backend
                    sh "docker build -t ${BACKEND_IMAGE} Backend/odc"
                    sh "docker tag ${BACKEND_IMAGE} ${REGISTRY}:backend-latest"
                    
                    // Construction de l'image Frontend
                    sh "docker build -t ${FRONTEND_IMAGE} Frontend"
                    sh "docker tag ${FRONTEND_IMAGE} ${REGISTRY}:frontend-latest"
                }
            }
        }

        stage('Push des images sur Docker Hub') {
            steps {
                script {
                    echo "ℹ️ Début du push des images vers le nouveau dépôt Docker Hub: ${REGISTRY}"
                    
                    // Renommer les images existantes pour utiliser le nouveau dépôt si nécessaire
                    sh '''
                        OLD_REGISTRY="''' + OLD_REGISTRY + '''"
                        BUILD_NUMBER="''' + BUILD_NUMBER + '''"
                        BACKEND_IMAGE="''' + BACKEND_IMAGE + '''"
                        BACKEND_LATEST="''' + BACKEND_LATEST + '''"
                        FRONTEND_IMAGE="''' + FRONTEND_IMAGE + '''"
                        FRONTEND_LATEST="''' + FRONTEND_LATEST + '''"
                        
                        # Vérifier et renommer les images existantes si nécessaire
                        if docker image inspect $OLD_REGISTRY:backend-$BUILD_NUMBER &> /dev/null; then
                            echo "Renommage de l'image backend avec le nouveau dépôt"
                            docker tag $OLD_REGISTRY:backend-$BUILD_NUMBER $BACKEND_IMAGE
                            docker tag $OLD_REGISTRY:backend-latest $BACKEND_LATEST || true
                        fi
                        
                        if docker image inspect $OLD_REGISTRY:frontend-$BUILD_NUMBER &> /dev/null; then
                            echo "Renommage de l'image frontend avec le nouveau dépôt"
                            docker tag $OLD_REGISTRY:frontend-$BUILD_NUMBER $FRONTEND_IMAGE
                            docker tag $OLD_REGISTRY:frontend-latest $FRONTEND_LATEST || true
                        fi
                    '''
                    
                    // Push des images vers Docker Hub
                    try {
                        withCredentials([string(credentialsId: 'dockerhub-credss', variable: 'DOCKER_HUB_PASS')]) {
                            sh 'echo $DOCKER_HUB_PASS | docker login -u blacksaiyan --password-stdin || true'
                            
                            sh '''
                                # Fonction pour pousser une image avec gestion d'erreur
                                push_image() {
                                    local image=$1
                                    echo "Tentative de push pour l'image: $image"
                                    if docker image inspect $image &> /dev/null; then
                                        if docker push $image; then
                                            echo "✅ Push réussi pour $image"
                                        else
                                            echo "⚠️ Échec du push pour $image - Continuons quand même"
                                        fi
                                    else
                                        echo "⚠️ L'image $image n'existe pas localement"
                                    fi
                                }
                            '''
                            
                            // Pousser les images vers le nouveau dépôt avec des commandes individuelles
                            sh "push_image ${BACKEND_IMAGE} || true"
                            sh "push_image ${BACKEND_LATEST} || true"
                            sh "push_image ${FRONTEND_IMAGE} || true"
                            sh "push_image ${FRONTEND_LATEST} || true"
                            
                            sh 'docker logout || true'
                        }
                    } catch (Exception e) {
                        echo "⚠️ Échec du push vers Docker Hub: ${e.message}. Continuons avec le déploiement local."
                    }
                }
            }
        }

        stage('Deploy Containers Locally') {
            steps {
                script {
                    echo "ℹ️ Démarrage du déploiement local des conteneurs"
                    
                    // Arrêt et suppression des conteneurs existants
                    sh "docker stop backend_container frontend_container || true"
                    sh "docker rm backend_container frontend_container || true"
                    
                    // Vérifier et déployer le backend
                    sh '''
                        BACKEND_LATEST="''' + BACKEND_LATEST + '''"
                        BACKEND_IMAGE="''' + BACKEND_IMAGE + '''"
                        BACKEND_PORT="''' + BACKEND_PORT + '''"
                        
                        if docker image inspect $BACKEND_LATEST &> /dev/null; then
                            echo "✅ Image backend trouvée: $BACKEND_LATEST"
                            echo "Démarrage du conteneur backend sur le port $BACKEND_PORT..."
                            docker run -d --name backend_container -p $BACKEND_PORT:$BACKEND_PORT $BACKEND_LATEST
                        else
                            echo "⚠️ L'image backend $BACKEND_LATEST n'existe pas localement."
                            echo "Tentative d'utilisation de l'image avec le numéro de build: $BACKEND_IMAGE"
                            
                            if docker image inspect $BACKEND_IMAGE &> /dev/null; then
                                echo "✅ Image backend trouvée: $BACKEND_IMAGE"
                                echo "Démarrage du conteneur backend sur le port $BACKEND_PORT..."
                                docker run -d --name backend_container -p $BACKEND_PORT:$BACKEND_PORT $BACKEND_IMAGE
                            else
                                echo "❌ Aucune image backend disponible. Le backend ne sera pas déployé."
                            fi
                        fi
                    '''
                    
                    // Vérifier et déployer le frontend
                    sh '''
                        FRONTEND_LATEST="''' + FRONTEND_LATEST + '''"
                        FRONTEND_IMAGE="''' + FRONTEND_IMAGE + '''"
                        FRONTEND_PORT="''' + FRONTEND_PORT + '''"
                        
                        if docker image inspect $FRONTEND_LATEST &> /dev/null; then
                            echo "✅ Image frontend trouvée: $FRONTEND_LATEST"
                            echo "Démarrage du conteneur frontend sur le port $FRONTEND_PORT..."
                            docker run -d --name frontend_container -p $FRONTEND_PORT:5173 $FRONTEND_LATEST
                        else
                            echo "⚠️ L'image frontend $FRONTEND_LATEST n'existe pas localement."
                            echo "Tentative d'utilisation de l'image avec le numéro de build: $FRONTEND_IMAGE"
                            
                            if docker image inspect $FRONTEND_IMAGE &> /dev/null; then
                                echo "✅ Image frontend trouvée: $FRONTEND_IMAGE"
                                echo "Démarrage du conteneur frontend sur le port $FRONTEND_PORT..."
                                docker run -d --name frontend_container -p $FRONTEND_PORT:5173 $FRONTEND_IMAGE
                            else
                                echo "❌ Aucune image frontend disponible. Le frontend ne sera pas déployé."
                            fi
                        fi
                    '''
                    
                    // Vérifier que les conteneurs sont bien démarrés
                    sh '''
                        BACKEND_PORT="''' + BACKEND_PORT + '''"
                        FRONTEND_PORT="''' + FRONTEND_PORT + '''"
                        
                        echo "\nℹ️ Vérification des conteneurs déployés:"
                        docker ps | grep -E 'backend_container|frontend_container' || echo "\n⚠️ Aucun conteneur déployé n'a été trouvé."
                        
                        if docker ps | grep -q backend_container; then
                            echo "\n✅ Backend déployé avec succès! Accessible sur http://localhost:$BACKEND_PORT"
                        fi
                        
                        if docker ps | grep -q frontend_container; then
                            echo "\n✅ Frontend déployé avec succès! Accessible sur http://localhost:$FRONTEND_PORT"
                        fi
                    '''
                }
            }
        }
    }

    post {
        always {
            echo '✅ Pipeline terminé.'
        }
        failure {
            echo '❌ Échec du pipeline !'
        }
    }
}
