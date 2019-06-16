pipeline {
    agent any
     parameters {
        string(defaultValue: "TEST", description: 'What environment?', name: 'userFlag')
        choice(choices: ['master', 'acc'], description: 'What branch ?', name: 'branch')
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh 'ls -la'
                //sh './gradlew build'
                archiveArtifacts artifacts: 'src/index.html'
                echo "My branch is: ${env.BRANCH_NAME}"
            }
        }
        stage('DeployToStage') {
            steps {
                echo 'stage step to be done'
                echo 'build docker'
                sh 'docker build -t helloapp:v1 .'
                echo 'push to registry'
                sh 'docker tag helloapp:v1 localhost:80/app/helloapp:v1'
                sh 'sudo docker login localhost:80 -u admin -u admin'
                sh 'sudo docker push localhost:80/app/helloapp:v1'
                echo 'images available in the catalog'
                sh 'curl -X GET http://localhost:80/v2/_catalog -u admin:admin'
                echo 'deploying using helm'
                sh 'helm install --name=helloapp --namespace=labs ./helm'
                sh 'helm list'
            }
        }
        stage('DeployToProd') {
            when {
                branch 'master'
            }
            steps {
                input 'Does the staging environment look OK?'
                milestone(1)
                echo 'prod step to be done'
            }
        }
    }
}
