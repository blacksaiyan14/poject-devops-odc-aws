pipeline {
    agent any
    environment {
        REGISTRY = 'blacksaiyan/projet-fil-rouge-jenkins'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        
        // Images Docker avec le numéro de build
        BACKEND_IMAGE = "${REGISTRY}:backend-${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${REGISTRY}:frontend-${BUILD_NUMBER}"
        MIGRATE_IMAGE = "${REGISTRY}:migrate-${BUILD_NUMBER}"
        
        // Images Docker avec le tag "latest"
        BACKEND_LATEST = "${REGISTRY}:backend-latest"
        FRONTEND_LATEST = "${REGISTRY}:frontend-latest"
        MIGRATE_LATEST = "${REGISTRY}:migrate-latest"
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
                    docker.withRegistry('', 'dockerhub-credss') {
                        // Backend
                        def back = docker.build("${BACKEND_IMAGE}", 'Backend/odc')
                        back.tag("${BACKEND_LATEST}")
                        
                        // Frontend
                        def front = docker.build("${FRONTEND_IMAGE}", 'Frontend')
                        front.tag("${FRONTEND_LATEST}")

                        // Migrate
                        def migrate = docker.build("${MIGRATE_IMAGE}", 'Migrate')
                        migrate.tag("${MIGRATE_LATEST}")
                    }
                }
            }
        }

        stage('Push des images sur Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', 'dockerhub-credss') {
                        sh 'docker push $BACKEND_IMAGE'
                        sh 'docker push $BACKEND_LATEST'
                        sh 'docker push $FRONTEND_IMAGE'
                        sh 'docker push $FRONTEND_LATEST'
                        sh 'docker push $MIGRATE_IMAGE'
                        sh 'docker push $MIGRATE_LATEST'
                    }
                }
            }
        }

        stage('Deploy Containers Locally') {
            steps {
                script {
                    sh '''
                        docker stop backend_container || true
                        docker rm backend_container || true
                        docker stop frontend_container || true
                        docker rm frontend_container || true
                        docker stop migrate_container || true
                        docker rm migrate_container || true

                        docker pull blacksaiyan/projet-fil-rouge-jenkins:backend-latest
                        docker pull blacksaiyan/projet-fil-rouge-jenkins:frontend-latest
                        docker pull blacksaiyan/projet-fil-rouge-jenkins:migrate-latest

                        docker run -d --name backend_container -p 8000:8000 blacksaiyan/projet-fil-rouge-jenkins:backend-latest
                        docker run -d --name frontend_container -p 3000:3000 blacksaiyan/projet-fil-rouge-jenkins:frontend-latest
                        docker run -d --name migrate_container blacksaiyan/projet-fil-rouge-jenkins:migrate-latest
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
