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
                sh './gradlew build'
                archiveArtifacts artifacts: 'src/index.html'
                echo "My branch is: ${env.BRANCH_NAME}"
            }
        }
        stage('DeployToStage') {
            when {
                branch 'master'
            }
            steps {
                echo 'stage step to be done'
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
