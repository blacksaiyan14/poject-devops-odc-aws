pipeline {
    agent any
    
    environment {
        DOCKER_BACKEND_IMAGE = 'blacksaiyan/backend'
        DOCKER_FRONTEND_IMAGE = 'blacksaiyan/frontend'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage ('Checkout') {
            steps {
                git branch: 'jenkins', url: 'https://github.com/blacksaiyan14/poject-devops-odc-aws.git'
            }
        }
        
        stage('Test Backend') {
            steps {
                sh 'apt-get update && apt-get install -y python3 python3-pip'
                dir('Backend/odc') {
                    sh 'pip3 install -r requirements.txt'
                    sh 'python3 manage.py test || true'  // Le || true permet de continuer même si les tests échouent
                }
            }
        }
        
        stage('Build Images') {
            steps {
                // Vérifier que Docker est installé
                sh 'docker --version'
                
                // Build Backend Image
                sh "docker build -t ${DOCKER_BACKEND_IMAGE}:${DOCKER_TAG} -f Backend/odc/Dockerfile Backend/odc"
                
                // Build Frontend Image
                sh "docker build -t ${DOCKER_FRONTEND_IMAGE}:${DOCKER_TAG} -f Frontend/Dockerfile Frontend"
            }
        }
        
        stage('Push Images') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-credentials', variable: 'DOCKER_HUB_CREDENTIALS')]) {
                    sh 'echo $DOCKER_HUB_CREDENTIALS | docker login -u blacksaiyan --password-stdin'
                    
                    // Push Backend Image
                    sh "docker push ${DOCKER_BACKEND_IMAGE}:${DOCKER_TAG}"
                    
                    // Push Frontend Image
                    sh "docker push ${DOCKER_FRONTEND_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // Mettre à jour les tags des images dans docker-compose.yaml
                sh "sed -i 's|image: backend|image: ${DOCKER_BACKEND_IMAGE}:${DOCKER_TAG}|g' docker-compose.yaml"
                sh "sed -i 's|image: frontend|image: ${DOCKER_FRONTEND_IMAGE}:${DOCKER_TAG}|g' docker-compose.yaml"
                
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