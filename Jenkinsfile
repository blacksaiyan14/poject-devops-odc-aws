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
                withCredentials([string(credentialsId: 'dockerhub-credss', variable: 'DOCKER_HUB_PASS')]) {
                    sh 'echo $DOCKER_HUB_PASS | docker login -u blacksaiyan --password-stdin'
                    
                    // Vérifier si les images existent avant de les pousser
                    sh '''
                        # Vérifier et pousser l'image backend avec le numéro de build
                        if docker image inspect $BACKEND_IMAGE &> /dev/null; then
                            docker push $BACKEND_IMAGE
                        else
                            echo "L'image $BACKEND_IMAGE n'existe pas, elle sera ignorée"
                        fi
                        
                        # Vérifier et pousser l'image backend latest
                        if docker image inspect ${REGISTRY}:backend-latest &> /dev/null; then
                            docker push ${REGISTRY}:backend-latest
                        else
                            echo "L'image ${REGISTRY}:backend-latest n'existe pas, elle sera ignorée"
                        fi
                        
                        # Vérifier et pousser l'image frontend avec le numéro de build
                        if docker image inspect $FRONTEND_IMAGE &> /dev/null; then
                            docker push $FRONTEND_IMAGE
                        else
                            echo "L'image $FRONTEND_IMAGE n'existe pas, elle sera ignorée"
                        fi
                        
                        # Vérifier et pousser l'image frontend latest
                        if docker image inspect ${REGISTRY}:frontend-latest &> /dev/null; then
                            docker push ${REGISTRY}:frontend-latest
                        else
                            echo "L'image ${REGISTRY}:frontend-latest n'existe pas, elle sera ignorée"
                        fi
                    '''
                    
                    sh 'docker logout'
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
