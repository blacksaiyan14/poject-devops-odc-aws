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

        stage('Build Images') {
            steps {
                script {
                    // Construction avec Buildx pour multi-architecture (optionnel)
                    docker.build("${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG}", "-f Backend/odc/Dockerfile Backend/odc")
                    docker.build("${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG}", "-f Frontend/Dockerfile Frontend")
                }
            }
        }

        stage('Push Images') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    passwordVariable: 'DOCKER_HUB_PASSWORD',
                    usernameVariable: 'DOCKER_HUB_USERNAME'
                )]) {
                    script {
                        // Version améliorée avec gestion propre des credentials
                        docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-hub-credentials') {
                            docker.image("${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG}").push()
                            docker.image("${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG}").push()
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Utilisation de variables pour une meilleure lisibilité
                    def composeFile = 'docker-compose.yaml'
                    
                    sh """
                        sed -i 's|image: ${DOCKER_BACKEND_IMAGE}:.*|image: ${DOCKER_BACKEND_IMAGE}:${DOCKER_BACKEND_TAG}|g' ${composeFile}
                        sed -i 's|image: ${DOCKER_FRONTEND_IMAGE}:.*|image: ${DOCKER_FRONTEND_IMAGE}:${DOCKER_FRONTEND_TAG}|g' ${composeFile}
                    """
                    
                    // Meilleure gestion des containers existants
                    sh 'docker-compose down --remove-orphans || true'
                    sh 'docker-compose up -d --build'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline exécuté avec succès !'
            slackSend(color: 'good', message: "Build ${BUILD_NUMBER} réussi - Images poussées sur Docker Hub")
        }
        failure {
            echo '❌ Le pipeline a échoué. Vérifie les logs Jenkins.'
            slackSend(color: 'danger', message: "Échec du build ${BUILD_NUMBER} - Vérifiez Jenkins")
        }
        always {
            script {
                // Nettoyage plus complet
                sh '''
                    docker system prune -af || true
                    rm -rf /tmp/docker || true
                '''
            }
        }
    }
}