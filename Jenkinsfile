pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'rlj' 
        DOCKERHUB_USER = 'genecodo'  

        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_PROJECT_KEY = 'red_line_front'     
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning red_line's repository from git📥"
                checkout scm 
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonar-tkn', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            docker run --rm \
                                --network host \
                                -e SONAR_HOST_URL=http://localhost:9000 \
                                -e SONAR_TOKEN=$SONAR_TOKEN \
                                -v "$(pwd)":/usr/src \
                                sonarsource/sonar-scanner-cli \
                                -Dsonar.projectKey=red_line_front \
                                -Dsonar.sources=. \
                                -Dsonar.exclusions=**/venv/**,**/node_modules/** \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Building Backend (Django)...') {
            steps {
                dir('./Backend/odc') {
                    echo "Creating the virtual environn⚙️"
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install --upgrade pip
                        pip install -r requirements.txt
                        python manage.py test
                    '''
                }
            }
        }

        stage('Building Frontend (React)...') {
            steps {
                dir('./Frontend') {
                    echo "⚙️ Installing the frontend part"
                    sh '''
                        export PATH=$PATH:/var/lib/jenkins/.nvm/versions/node/v22.15.0/bin/
                        npm install
                        npm run build
                       # npm test -- --watchAll=false
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    echo "🐳 Building the backend image"
                    sh "docker build -t ${DOCKERHUB_USER}/backend_red_line:latest -f ./Backend/odc/dockerfile ./Backend/odc"

                    echo "🐳 CBuilding the frontend image"
                    sh "docker build -t ${DOCKERHUB_USER}/frontend_red_line:latest -f ./Frontend/dockerfile ./Frontend"
                }
            }
        }

        stage('Pushing to Docker Hub') {
            steps {
                echo "Pushing images to Docker Hub 🚀"
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_USER/backend_red_line:latest
                        docker push $DOCKER_USER/frontend_red_line:latest
                    '''
                }
            }
        }
        stage('run'){
            steps{
                sh '''
                echo ${PWD} && ls -l
                docker compose down || true
                docker compose build
                '''
            }
        }
    }

    post {
        failure {
            mail to: 'kalamouu@gmail.com',
                 subject: "❌ Échec du pipeline Jenkins",
                 body: "Le pipeline a échoué. Vérifie Jenkins pour plus de détails."
        }
        success {
            mail to: 'kalamouu@gmail.com',
                 subject: "✅ Pipeline Jenkins réussi",
                 body: "Tout s'est bien passé. L'application est déployée ! 🎉"
        }
    }
}
