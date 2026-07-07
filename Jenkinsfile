pipeline {

    agent any

    environment {
        IMAGE_NAME = "task-tracker"
        CONTAINER_NAME = "task-tracker"
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
                sh 'npm install'
                sh 'npm test'
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
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

                echo ""
                echo "==============================="
                echo "GET /health"
                curl http://localhost:${APP_PORT}/health

                echo ""
                echo "==============================="
                echo "GET /api/tasks"
                curl http://localhost:${APP_PORT}/api/tasks

                echo ""
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
