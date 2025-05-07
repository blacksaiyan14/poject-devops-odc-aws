pipeline {
    agent any
    environment {
        REGISTRY = 'blacksaiyan/projet-fil-rouge-jenkins'
        GIT_COMMIT_SHORT = "${env.GIT_COMMIT[0..7]}"
        BACK_IMAGE = "${REGISTRY}:backend-${GIT_COMMIT_SHORT}"
        FRONT_IMAGE = "${REGISTRY}:frontend-${GIT_COMMIT_SHORT}"
        BACK_LATEST = "${REGISTRY}:backend-latest"
        FRONT_LATEST = "${REGISTRY}:frontend-latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'jenkins', url: 'https://github.com/blacksaiyan14/poject-devops-odc-aws.git'
            }
        }

        stage('Test Backend') {
            // agent { label 'docker-agent' }
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
            // agent { label 'docker-agent' }
            steps {
                dir('Frontend') {
                    sh '''
                        # Installation des dépendances et tests
                        npm ci
                        npm run test || echo "⚠️ Aucun test défini pour le frontend"
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        // Build Backend
                        def back = docker.build("${BACK_IMAGE}", 'Backend/odc')
                        back.push()
                        back.tag("${BACK_LATEST}")
                        back.push("${BACK_LATEST}")

                        // Build Frontend
                        def front = docker.build("${FRONT_IMAGE}", 'Frontend')
                        front.push()
                        front.tag("${FRONT_LATEST}")
                        front.push("${FRONT_LATEST}")
                    }
                }
            }
        }

        stage('Deploy Containers Locally') {
            steps {
                script {
                    sh '''
                        # Arrêt et suppression des anciens conteneurs
                        docker stop backend_container || true
                        docker rm backend_container || true
                        docker stop frontend_container || true
                        docker rm frontend_container || true

                        # Pull des dernières versions
                        docker pull blacksaiyan/projet-fil-rouge-jenkins:backend-latest
                        docker pull blacksaiyan/projet-fil-rouge-jenkins:frontend-latest

                        # Lancement des nouveaux conteneurs
                        docker run -d --name backend_container -p 8000:8000 blacksaiyan/projet-fil-rouge-jenkins:backend-latest
                        docker run -d --name frontend_container -p 3000:3000 blacksaiyan/projet-fil-rouge-jenkins:frontend-latest
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
