pipeline {

    agent any

    environment {

        REGISTRY = "likithus"
        IMAGE_NAME = "task-tracker"

        IMAGE_TAG = "${BUILD_NUMBER}"

        DOCKER_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

        PREVIOUS_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER.toInteger()-1}"

        APP_PORT = "3000"

        EMAIL = "workpersonaladi@gmail.com"

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
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                    echo "$DOCKER_PASS" | docker login $REGISTRY -u "$DOCKER_USER" --password-stdin
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
