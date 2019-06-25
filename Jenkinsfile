//Name of credential object in Jenkins
creds = "apic-apidev"
commitId = "001"
appName = "mySampleApp".toLowerCase()
namespace = "labs"
    parameters {
        string(defaultValue: "mysampleapp", description: 'name of the app', name: 'appNameParam')
        //choice(choices: ['master', 'acc'], description: 'What branch ?', name: 'branch')
    }
 
node {    

    try{
        //load server env.
        //load "$JENKINS_HOME/.envvars/apicenv"
        // intServer = env.apichost
        
        echo "Workspace: ${env.WORKSPACE}"
 
        sh 'ls -la'
        sh 'git log --abbrev-commit --pretty=oneline -1'

        commitId = sh (
          			script: 'git log --abbrev-commit --pretty=oneline -1 | awk  \'{print $1}\'',
          			returnStdout: true
        		).trim()
        echo "commit id: ${commitId} " 
        //Publish to integration server
        deploy(creds, commitId, appName, namespace)  

    } catch(exe)
    {
        echo "${exe}"
        error("[FAILURE] Failed to initialize")
    }
}    

def deploy(String creds, String commitId, String myAppName, String namespace) {
        
        //Login to Dev Server
        try {
            echo "Accept license"
        } catch(exe){
            echo "Failed to accept license with Status Code: ${exe}"
            throw exe                       
        }  
        
        stage ('Build') {
                echo 'Running build automation'
                imageName = namespace + "/" + myAppName + ":" + commitId
                echo "building ${imageName}"
                docimg = docker.build(imageName)
        } 
        stage ('reg-load') {
            echo 'Loading built image into registry'
                
                /*script {
                    docker.withRegistry('http://localhost:80/app/', 'docker-registry') {
                        docimg.push("v2")
                    }
                 }*/
                //sh 'docker build -t helloapp:v1 .'
                //echo 'push to registry'
                //sh 'docker tag helloapp:v1 localhost:80/app/helloapp:v1'
                //sh 'docker push localhost:80/app/helloapp:v1'
                echo 'images available in the catalog'
                //sh 'curl -X GET http://localhost:80/v2/_catalog -u x:y'
                //echo 'deploying using helm'
                //sh 'helm install --name=helloapp --namespace=labs ./helm'
                //sh 'helm list'

        }
}


