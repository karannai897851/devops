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
                sh 'docker run -d -p 8081:8081 cw2-server:1.1'
                sh 'sleep 5'
                sh 'curl -f http://localhost:8081 || echo "App not responding!"'
                sh 'docker ps'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker tag cw2-server:1.1 $USER/cw2-server:1.1'
                    sh 'docker push $USER/cw2-server:1.1'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            environment {
                KUBECONFIG = '/var/lib/jenkins/.kube/config'
            }
            steps {
                sh 'kubectl set image deployment/devops-app devops-app=karan43124/cw2-server:1.1'
            }
        }
    }
}
