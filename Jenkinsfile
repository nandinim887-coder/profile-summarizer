pipeline {
    agent any

    environment {
        IMAGE_NAME = "nandini88847/github-profile-summarizer"
        IMAGE_TAG  = "v7"
        MAX_REPOS  = "50"
    }

    stages {

        // 1️⃣ Checkout code
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // 2️⃣ Build Node app inside Docker
        stage('Build (Node)') {
            steps {
                sh '''
                set -e
                MSYS_NO_PATHCONV=1 docker run --rm \
                  -v "$WORKSPACE:/app" \
                  -w /app \
                  node:20-alpine \
                  sh -c "npm install --cache /tmp/.npm && npm run build"
                '''
            }
        }

        // 3️⃣ Build Docker image
        stage('Docker Build') {
            steps {
                withCredentials([string(
                    credentialsId: 'github-token-secret',
                    variable: 'GITHUB_TOKEN_VALUE'
                )]) {
                    sh '''
                    docker build \
                      --build-arg VITE_GITHUB_TOKEN=$GITHUB_TOKEN_VALUE \
                      --build-arg VITE_MAX_REPOS=50 \
                      -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    '''
                }
            }
        }

        // 4️⃣ Docker Login & Push
        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DockerHub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        // 5️⃣ Deploy container
        stage('Deploy Image') {
            steps {
                sh '''
                docker rm -f github-profile-summarizer || true
                docker run -d \
                  --name github-profile-summarizer \
                  -p 8081:80 \
                  ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Docker image pushed and deployed: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}
