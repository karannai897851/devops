pipeline {
    agent any
    environment {
        IMAGE = 'karan43124/cw2-server:1.1'
    }
    stages {

        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/karannai897851/devops.git'
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
                sh 'docker build -t cw2-server:1.1 .'
            }
        }

        stage('Test Container') {
            steps {
                sh '''
                    # Stop container using port 8081, if running
                    CONTAINER_ID=$(docker ps -q --filter "publish=8081")
                    if [ ! -z "$CONTAINER_ID" ]; then
                      echo "Stopping container using port 8081..."
                      docker stop $CONTAINER_ID
                    fi
        
                    # Remove devops-test container if it already exists
                    docker rm -f devops-test || true
        
                    # Run new test container
                    docker run -d --name devops-test -p 8081:8081 cw2-server:1.1
        
                    # Wait and test
                    sleep 5
                    curl -f http://localhost:8081 || echo "App not responding!"
                    docker ps
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo $PASS | docker login -u $USER --password-stdin
                        docker tag cw2-server:1.1 $USER/cw2-server:1.1
                        docker push $USER/cw2-server:1.1
                    '''
                }
            }
        }

        stage('Ensure Kubernetes Deployment') {
            steps {
                sh '''
                    export HOME=/var/lib/jenkins
                    export KUBECONFIG=/var/lib/jenkins/.kube/config
        
                    # Create deployment if not exists
                    if ! kubectl get deployment devops-app > /dev/null 2>&1; then
                      kubectl create deployment devops-app --image=karan43124/cw2-server:1.1
                      kubectl expose deployment devops-app --type=NodePort --port=8081
                    fi
                '''
            }
        }


        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    export HOME=/var/lib/jenkins
                    export KUBECONFIG=/var/lib/jenkins/.kube/config
                    kubectl set image deployment/devops-app devops-app=karan43124/cw2-server:1.1
                '''
            }
        }

        stage('Cleanup Test Container') {
            steps {
                sh 'docker rm -f devops-test || true'
            }
        }
    }
}
