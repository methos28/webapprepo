pipeline {
    agent any

    environment {
        IMAGE_NAME      = "python-webapp"
        IMAGE_TAG       = "${BUILD_NUMBER}-${GIT_COMMIT.take(7)}"
        DOCKERHUB_USER  = "methos28"
        CONTAINER_NAME  = "python-webapp"
        APP_PORT        = "1234"
        INTERNAL_PORT   = "80"
        DEPLOY_HOST     = "methos@192.168.18.129"
    }

    stages {

        stage('Verify Workspace') {
            steps {
                sh '''
                echo "Workspace: $WORKSPACE"
                ls -la
                '''
            }
        }
        
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub_creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker tag $IMAGE_NAME:$IMAGE_TAG $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG
                docker push $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy to Server') {
            steps {
                sshagent(credentials: ['prod-server-ssh']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $DEPLOY_HOST '
                        docker pull '"$DOCKERHUB_USER"'/'"$IMAGE_NAME"':'"$IMAGE_TAG"' &&
                        docker rm -f '"$CONTAINER_NAME"' || true &&
                        docker run -d \
                          --name '"$CONTAINER_NAME"' \
                          -p '"$APP_PORT"':'"$INTERNAL_PORT"' \
                          '"$DOCKERHUB_USER"'/'"$IMAGE_NAME"':'"$IMAGE_TAG"'
                    '
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning workspace and Docker leftovers"

            cleanWs()

            sh '''
            docker container prune -f
            docker image prune -f
            docker logout
            '''
        }
    }
}
