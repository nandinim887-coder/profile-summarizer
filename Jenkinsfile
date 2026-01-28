pipeline {
    agent any

    environment {
        IMAGE_NAME = "nandini88847/github-profile-summarizer"
        IMAGE_TAG  = "v7"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build (Node)') {
            steps {
                sh '''
                docker run --rm \
                  -v "$PWD:/app" \
                  -w /app \
                  node:20-alpine \
                  sh -c "npm install && npm run build"
                '''
            }
        }

        stage('Docker Build') {
            steps {
                withCredentials([string(credentialsId: 'GITHUB_TOKEN', variable: 'GITHUB_TOKEN_VALUE')]) {
                    sh '''
                    docker build \
                      --build-arg VITE_GITHUB_TOKEN=$GITHUB_TOKEN_VALUE \
                      --build-arg VITE_MAX_REPOS=50 \
                      -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    '''
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DockerHub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "Docker user is: $DOCKER_USER"
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                sh '''
                docker push ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Docker image pushed successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}
