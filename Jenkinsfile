pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'https://hub.docker.com/repository/docker/blacksaiyan/projet-fil-rouge-jenkins/'
        DOCKER_BACKEND_IMAGE = 'blacksaiyan/projet-fil-rouge-jenkins/backend'
        DOCKER_FRONTEND_IMAGE = 'blacksaiyan/projet-fil-rouge-jenkins/frontend'
        DOCKER_BACKEND_TAG = "${env.BUILD_NUMBER}"
        DOCKER_FRONTEND_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage ('Checkout') {
            steps {
                git branch: 'jenkins', url: 'https://github.com/blacksaiyan14/poject-devops-odc-aws.git'
            }
        }
        
        stage('Test Backend') {
            steps {
                dir('Backend/odc') {
                    sh 'pip install -r requirements.txt'
                    sh 'python manage.py test'
                }
            }
        }
        
        stage('Build Images') {
            steps {
                // Build Backend Image
                sh "docker build -t ${DOCKER_REGISTRY}/${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG} -f Backend/odc/Dockerfile Backend/odc"
                
                // Build Frontend Image
                sh "docker build -t ${DOCKER_REGISTRY}/${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG} -f Frontend/Dockerfile Frontend"
            }
        }
        
        stage('Push Images') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-credentials', variable: 'DOCKER_HUB_CREDENTIALS')]) {
                    sh 'echo $DOCKER_HUB_CREDENTIALS | docker login -u blacksaiyan --password-stdin'
                    
                    // Push Backend Image
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG}"
                    
                    // Push Frontend Image
                    sh "docker push ${DOCKER_REGISTRY}/${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG}"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // Mettre à jour les tags des images dans docker-compose.yaml
                sh "sed -i 's|image: backend|image: ${DOCKER_REGISTRY}/${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG}|g' docker-compose.yaml"
                sh "sed -i 's|image: frontend|image: ${DOCKER_REGISTRY}/${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG}|g' docker-compose.yaml"
                
                // Déployer avec docker-compose
                sh 'docker-compose down'
                sh 'docker-compose up -d'
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline exécuté avec succès!'
        }
        failure {
            echo 'Le pipeline a échoué. Veuillez vérifier les logs.'
        }
        always {
            // Nettoyage des images Docker non utilisées
            sh 'docker system prune -f'
        }
    }
}