pipeline {

    agent any

    environment {
        IMAGE_NAME = "task-tracker"
        APP_PORT = "3000"
    }

    stages {

        stage('SCM Pull') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies and Run Tests') {
            steps {
                sh '''
                docker run --rm \
                    -v "$WORKSPACE":/app \
                    -w /app \
                    node:20-alpine \
                    sh -c "npm install && npm test"
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                docker build -t ${IMAGE_NAME} .
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker compose down || true
                docker compose up -d --build
                '''
            }
        }

        stage('Curl Verification') {
            steps {
                sh '''
                echo "Waiting for application..."
                sleep 10

                echo "==============================="
                echo "GET /"
                curl http://localhost:${APP_PORT}/

                echo
                echo "==============================="
                echo "GET /health"
                curl http://localhost:${APP_PORT}/health

                echo
                echo "==============================="
                echo "GET /api/tasks"
                curl http://localhost:${APP_PORT}/api/tasks
                '''
            }
        }
    }

    post {
        always {
            echo "Cleaning up..."

            sh '''
            docker compose down || true
            docker image prune -f
            '''

            cleanWs()
        }
    }
}
