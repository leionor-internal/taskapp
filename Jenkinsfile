pipeline {

    agent any

    environment {
        IMAGE_NAME = "task-tracker"
        APP_PORT = "3000"
    }
pipeline {

    agent any

    environment {

        REGISTRY = "registry.example.com"
        IMAGE_NAME = "task-tracker"

        IMAGE_TAG = "${BUILD_NUMBER}"

        DOCKER_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

        PREVIOUS_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER.toInteger()-1}"

        APP_PORT = "3000"

        EMAIL = "admin@example.com"

    }

    options {

        timestamps()

        buildDiscarder(logRotator(numToKeepStr: '10'))

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

                npm install

                npm test

                '''

            }

        }

        stage('Docker Login') {

            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-registry',
                        usernameVariable: 'USERNAME',
                        passwordVariable: 'PASSWORD'
                    )
                ]) {

                    sh '''
                    echo "$PASSWORD" | docker login $REGISTRY -u "$USERNAME" --password-stdin
                    '''

                }

            }

        }

        stage('Build Image') {

            steps {

                sh '''

                export DOCKER_BUILDKIT=1

                docker build \
                    --cache-from=${REGISTRY}/${IMAGE_NAME}:latest \
                    -t ${DOCKER_IMAGE} \
                    -t ${REGISTRY}/${IMAGE_NAME}:latest .

                '''

            }

        }

        stage('Push Image') {

            steps {

                sh '''

                docker push ${DOCKER_IMAGE}

                docker push ${REGISTRY}/${IMAGE_NAME}:latest

                '''

            }

        }

        stage('Deploy') {

            steps {

                sh '''

                export DOCKER_IMAGE=${DOCKER_IMAGE}

                docker compose down || true

                docker compose up -d

                '''

            }

        }

        stage('Readiness Check') {

            steps {

                sh '''

                echo "Waiting for application..."

                timeout=60

                until curl -s http://localhost:${APP_PORT}/health

                do

                    sleep 2

                    timeout=$((timeout-2))

                    if [ $timeout -le 0 ]; then
                        exit 1
                    fi

                done

                '''

            }

        }

        stage('Curl Verification') {

            steps {

                sh '''

                echo "Root Endpoint"

                curl http://localhost:${APP_PORT}/

                echo

                echo "Health Endpoint"

                curl http://localhost:${APP_PORT}/health

                echo

                echo "Tasks Endpoint"

                curl http://localhost:${APP_PORT}/api/tasks

                '''

            }

        }

    }

    post {

        success {

            echo "Deployment Successful"

            mail(
                to: EMAIL,
                subject: "SUCCESS : Build ${BUILD_NUMBER}",
                body: "Deployment Successful"
            )

        }

        failure {

            echo "Deployment Failed"

            sh '''

            docker pull ${PREVIOUS_IMAGE} || true

            export DOCKER_IMAGE=${PREVIOUS_IMAGE}

            docker compose down || true

            docker compose up -d || true

            '''

            mail(
                to: EMAIL,
                subject: "FAILED : Build ${BUILD_NUMBER}",
                body: "Deployment Failed. Rollback attempted."
            )

        }

        always {

            sh '''

            docker image prune -f

            docker container prune -f

            docker builder prune -f

            '''

            cleanWs()

        }

    }

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
