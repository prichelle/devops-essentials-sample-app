//Name of credential object in Jenkins
creds = "apic-apidev"
commitId = "001"
appName = "mysampleapp".toLowerCase()
registryURL = "http://localhost:80";
appColor = "green"

namespace = "labs"


//parameters {
    //string(defaultValue: "mysampleapp", description: 'name of the app', name: 'appNameParam')
    //choice(choices: ['master', 'acc'], description: 'What branch ?', name: 'branch')
//}
 
node {    

    try{
        //load server env.
        //load "$JENKINS_HOME/.envvars/apicenv"
        // intServer = env.apichost
        
        echo "Workspace: ${env.WORKSPACE}"
 
        checkout scm
        //sh 'ls -la'
 

        commitId = sh (
          			script: 'git log --abbrev-commit --pretty=oneline -1 | awk  \'{print $1}\'',
          			returnStdout: true
        		).trim()

        echo "commit id: ${commitId} " 
        commitId = "562271c"

        //publish(creds, commitId, appName, namespace, registryURL)  
        deployincluster(registryURL, namespace, appName, commitId, appColor)

    } catch(exe)
    {
        echo "${exe}"
        error("[FAILURE] Failed to initialize")
    }
}    

def publish(String creds, String commitId, String myAppName, String namespace, String registryURL) {
        
        stage ('Build') {
                echo 'Running build automation'
                imageName = namespace + "/" + myAppName + ":" + commitId
                echo "building ${imageName}"
                docimg = docker.build(imageName)
        } 
        stage ('reg-load') {
            echo 'Loading built image into registry'
                
            script {
                docker.withRegistry(registryURL, 'docker-registry') {
                    docimg.push(commitId)
                }
            }
            echo 'images available in the catalog'
            withCredentials([usernameColonPassword(credentialsId: 'docker-registry', variable: 'USERPASS')]) {
                sh 'curl -X GET http://localhost:80/v2/_catalog -u $USERPASS'
            }
        }

}

def deployincluster(String registryURL, String namespace, String appName, String commitId, String appColor){
    
    echo 'deploying using helm'
    sh "sed -i 's|IM_URI|${registryURL}/${namespace}/${appName}|g' ./helm/values.yaml" 
    sh "sed -i 's|IM_TAG|${commitId}|g' ./helm/values.yaml"
    sh "sed -i 's|APP_COLOR|${appColor}|g' ./helm/values.yaml"
    // sh "sed -i back 's|APP_PORT|${appPort}|g' ./helm/values.yaml"
    sh "cat ./helm/values.yaml"
    
    sh "helm install --name=${appName}-${commitId} --namespace=${namespace} ./helm"
    sh 'helm list'
    
    
    // kubectl get svc -n labs --show-labels | grep green | awk '{print $1}'
    // helm install --namespace=labs . --name myapp-562271c
}
