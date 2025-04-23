pipeline {
    agent any
    environment {
        DOCKERHUB_USER = 'karan43124'
        IMAGE_NAME = 'cw2-server'
    }
    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/karannai897851/devops.git'
            }
        }

        stage('Generate Image Tag') {
            steps {
                script {
                    COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    IMAGE_TAG = "${DOCKERHUB_USER}/${IMAGE_NAME}:${COMMIT_HASH}"
                    env.IMAGE_TAG = IMAGE_TAG
                }
            }
        }

        stage('Debug Workspace') {
            steps {
                sh 'ls -la'
                sh 'cat server.js || echo "server.js not found"'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_TAG} ."
            }
        }

        stage('Test Container') {
            steps {
                sh """
                    docker rm -f devops-test || true
                    docker run -d --name devops-test -p 8081:8081 ${IMAGE_TAG}
                    sleep 5
                    curl -f http://localhost:8081 || echo "App not responding!"
                    docker ps
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo \$PASS | docker login -u \$USER --password-stdin
                        docker push ${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Ensure Kubernetes Deployment') {
            steps {
                sh """
                    export HOME=/var/lib/jenkins
                    export KUBECONFIG=/var/lib/jenkins/.kube/config

                    if ! kubectl get deployment devops-app > /dev/null 2>&1; then
                        kubectl create deployment devops-app --image=${IMAGE_TAG}
                        kubectl expose deployment devops-app --type=NodePort --port=8081
                    fi
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    export HOME=/var/lib/jenkins
                    export KUBECONFIG=/var/lib/jenkins/.kube/config
                    kubectl set image deployment/devops-app cw2-server=${IMAGE_TAG} || \
                    kubectl set image deployment/devops-app ${IMAGE_NAME}=${IMAGE_TAG}
                """
            }
        }

        stage('Cleanup Test Container') {
            steps {
                sh 'docker rm -f devops-test || true'
            }
        }
    }
}
