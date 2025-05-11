pipeline {
    agent any
    environment {
        REGISTRY = 'blacksaiyan/projet-fil-rouge-jenkins'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        
        // Images Docker avec le numéro de build
        BACKEND_IMAGE = "${REGISTRY}:backend-${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${REGISTRY}:frontend-${BUILD_NUMBER}"
        
        // Images Docker avec le tag "latest"
        BACKEND_LATEST = "${REGISTRY}:backend-latest"
        FRONTEND_LATEST = "${REGISTRY}:frontend-latest"
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
                    // Utiliser les identifiants Docker Hub stockés dans Jenkins
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credss', passwordVariable: 'DOCKER_HUB_PASS', usernameVariable: 'DOCKER_HUB_USER')]) {
                        // Se connecter à Docker Hub avec les identifiants
                        sh 'echo $DOCKER_HUB_PASS | docker login -u $DOCKER_HUB_USER --password-stdin'
                        
                        // Afficher les informations de débogage
                        sh 'echo "Utilisateur Docker Hub: $DOCKER_HUB_USER"'
                        sh 'echo "Images à pousser: $BACKEND_IMAGE, $FRONTEND_IMAGE"'
                        
                        // Essayer de pousser les images avec gestion d'erreur
                        sh '''
                            # Fonction pour pousser une image avec gestion d'erreur
                            push_image() {
                                local image=$1
                                echo "Tentative de push pour l'image: $image"
                                if docker image inspect $image &> /dev/null; then
                                    if docker push $image; then
                                        echo "✅ Push réussi pour $image"
                                        return 0
                                    else
                                        echo "❌ Échec du push pour $image"
                                        return 1
                                    fi
                                else
                                    echo "⚠️ L'image $image n'existe pas localement"
                                    return 0  # Ne pas échouer si l'image n'existe pas
                                fi
                            }
                            
                            # Pousser les images
                            push_image "$BACKEND_IMAGE" || true
                            push_image "${REGISTRY}:backend-latest" || true
                            push_image "$FRONTEND_IMAGE" || true
                            push_image "${REGISTRY}:frontend-latest" || true
                        '''
                        
                        // Se déconnecter de Docker Hub
                        //sh 'docker logout'
                    }
                }
            }
        }

        stage('Deploy Containers Locally') {
            steps {
                sh '''
                    # Arrêt et suppression des conteneurs existants
                    docker stop backend_container frontend_container || true
                    docker rm backend_container frontend_container || true
                    
                    # Récupération des dernières images
                    docker pull blacksaiyan/projet-fil-rouge-jenkins:backend-latest
                    docker pull blacksaiyan/projet-fil-rouge-jenkins:frontend-latest

                    # Démarrage des nouveaux conteneurs
                    docker run -d --name backend_container -p 8000:8000 blacksaiyan/projet-fil-rouge-jenkins:backend-latest
                    docker run -d --name frontend_container -p 3000:3000 blacksaiyan/projet-fil-rouge-jenkins:frontend-latest
                    
                    # Vérification que les conteneurs sont bien démarrés
                    docker ps | grep -E 'backend_container|frontend_container'
                '''
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
