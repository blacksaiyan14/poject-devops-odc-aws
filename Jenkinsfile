pipeline {
    agent any

    environment {
        DOCKER_USER = 'blacksaiyan'
        BACKEND_IMAGE = "${DOCKER_USER}/backend"
        FRONTEND_IMAGE = "${DOCKER_USER}/frontend"
        MIGRATE_IMAGE = "${DOCKER_USER}/migrate"
    }

    stages {
        stage('Cloner le dépôt') {
            steps {
                git branch: 'jenkins',
                    url: 'https://github.com/blacksaiyan14/poject-devops-odc-aws.git'
            }
        }

       /* stage('Tests') {
            steps {
                sh '''
                    cd Backend
                    pip install -r requirements.txt
                    pytest
                '''
                sh '''
                    cd Frontend
                    npm install
                    npm test
                '''
            }
        }
        */

        stage('Build des images') {
            steps {
                script {
                    // Ajoutez --no-cache si nécessaire pour forcer une reconstruction complète
                    sh 'docker build --no-cache -t $FRONTEND_IMAGE:latest -f Frontend/Dockerfile Frontend'
                    sh 'docker build --no-cache -t $BACKEND_IMAGE:latest -f Backend/odc/Dockerfile Backend/odc'
                    sh 'docker build --no-cache -t $MIGRATE_IMAGE:latest -f Backend/odc/Dockerfile Backend/odc'
                }
            }
        }

        stage('Push des images sur Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh 'docker push $BACKEND_IMAGE:latest'
                    sh 'docker push $FRONTEND_IMAGE:latest'
                    sh 'docker push $MIGRATE_IMAGE:latest'
                }
            }
        }

        stage('Déploiement local avec Docker Compose') {
            steps {
                sh '''
                    docker-compose down || true
                    docker-compose pull
                    docker-compose up -d --build
                '''
            }
        }
    }

    post {
        success {
            mail to: 'alassanebenzecoly@gmail.com',
                 subject: "✅ Déploiement local réussi",
                 body: "L'application a été déployée localement avec succès."
        }
        failure {
            mail to: 'alassanebenzecoly@gmail.com',
                 subject: "❌ Échec du pipeline Jenkins",
                 body: "Une erreur s’est produite, merci de vérifier Jenkins."
        }
    }
}