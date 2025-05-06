pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_BACKEND_IMAGE = 'blacksaiyan/projet-fil-rouge-jenkins-backend'
        DOCKER_FRONTEND_IMAGE = 'blacksaiyan/projet-fil-rouge-jenkins-frontend'
        DOCKER_BACKEND_TAG = "${BUILD_NUMBER}"
        DOCKER_FRONTEND_TAG = "${BUILD_NUMBER}"
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
                    sh 'sudo apt-get update && sudo apt-get install -y gcc python3-dev libpq-dev' // pour psycopg2
                    sh 'pip install --upgrade pip'
                    sh 'pip install -r requirements.txt'
                    sh 'python manage.py test'
                }
            }
        }

        stage('Build Images') {
            steps {
                sh "docker build -t ${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG} -f Backend/odc/Dockerfile Backend/odc"
                sh "docker build -t ${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG} -f Frontend/Dockerfile Frontend"
            }
        }

        stage('Push Images') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-credentials', variable: 'DOCKER_HUB_PASSWORD')]) {
                    sh 'echo $DOCKER_HUB_PASSWORD | docker login -u blacksaiyan --password-stdin'
                    sh "docker push ${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG}"
                    sh "docker push ${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG}"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "sed -i 's|image: backend.*|image: ${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG}|g' docker-compose.yaml"
                sh "sed -i 's|image: frontend.*|image: ${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG}|g' docker-compose.yaml"

                sh 'docker-compose down'
                sh 'docker-compose up -d'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline exécuté avec succès !'
        }
        failure {
            echo '❌ Le pipeline a échoué. Vérifie les logs Jenkins.'
        }
        always {
            script {
                sh 'docker system prune -f || true'
            }
        }
    }
}
