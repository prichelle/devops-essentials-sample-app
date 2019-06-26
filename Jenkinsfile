//Name of credential object in Jenkins
creds = "apic-apidev"
commitId = "001"
appName = "mysampleapp".toLowerCase()
registryHost = "localhost:80";

registryURL = "http://" + registryHost

appColor = "green"
currAppColor = "blue"
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
        echo "set commit id to 562271c for test"
        //commitId = "562271c"
        commitId = "67f02b1"
        
        appName = sh (
                            script: "cat ./helm/Chart.yaml | grep name | awk '{print \$2}'",
                            returnStdout: true
                        ).trim()

        echo "deploying app: ${appName}" 

        echo "getting Ingress information"

        currentIngressName = sh (
                        script: "kubectl get ingress -n ${namespace} | grep ${appName} | awk '{print \$1}'",
                        returnStdout: true
                    ).trim()


        // searching the current color of the exposed service
        if (currentIngressName) {
            exposedSvcId = sh (
                            script: "kubectl get ingress -n ${namespace} ${appName} -o jsonpath=\"{.spec.rules[*].http.paths[*].backend.serviceName}\"",
                            returnStdout: true
                        ).trim()
            currAppColor = sh (
                            script: "kubectl get svc -n ${namespace} ${exposedSvcId} -o jsonpath=\"{.metadata.labels.color}\"",
                            returnStdout: true
                        ).trim()
            echo "current service ${exposedSvcId} tainted with color ${currAppColor}"

            //default color for target service is green. So if exposed service is green the target color need to be set to blue
            if (currAppColor == "green"){
                appColor = "blue"
            }
        } 

        echo "tainting current deployment to color ${appColor}"

        //publish(creds, commitId, appName, namespace, registryURL)  


        deployincluster(registryHost, namespace, appName, commitId, appColor)
        updateIngress( namespace,  appColor, appName)

        removeOldDeployment(namespace, currAppColor)

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
                sh "curl -X GET ${registryURL}/v2/_catalog -u $USERPASS"
            }
        }

}

def deployincluster(String registryHost, String namespace, String appName, String commitId, String appColor){
    
    stage ('deploy-img'){

        //echo "getting the current service name"
        //kubectl get ingress -n labs helloapp -o jsonpath="{.spec.rules[*].http.paths[*].backend.serviceName}"
        echo 'deploying using helm'
        echo "setting image name to ${registryHost}/${namespace}/${appName}" 
        sh "sed -i 's|IM_URI|${registryHost}/${namespace}/${appName}|g' ./helm/values.yaml" 

        echo "setting image tag to ${commitId}"
        sh "sed -i 's|IM_TAG|${commitId}|g' ./helm/values.yaml"

        echo "setting app color to ${appColor}" 
        sh "sed -i 's|APP_COLOR|${appColor}|g' ./helm/values.yaml"
        // sh "sed -i back 's|APP_PORT|${appPort}|g' ./helm/values.yaml"
        sh "cat ./helm/values.yaml"
        
        sh "helm install --name=${appName}-${commitId} --namespace=${namespace} ./helm"
        sh 'helm list'
         // kubectl get svc -n labs --show-labels | grep green | awk '{print $1}'
        // helm install --namespace=labs . --name myapp-562271c
    }
}

def updateIngress(String namespace, String appColor, String appName){

    stage ('updateIngress'){

        script {
            updateIngress = input message: 'Update Ingress',
              parameters: [choice(name: 'Update Ingress', choices: 'no\nyes', description: "Choose yes if you want to expose service tainted in ${appColor}")]
        }
        if (updateIngress == "yes") { 
            echo "initializing ingress yaml file"   

            //getting the svc deployed with the target color
            // we need to ensure that the service with the required tainted color is deployed
            svcId = sh (
                            script: "kubectl get svc -n ${namespace} -l color=${appColor},name=${appName} | awk 'FNR==2{print \$1}'",
                            returnStdout: true
                        ).trim()

            if (svcId){
                echo "service to be exposed svc: ${svcId} that is tainted with color: ${appColor}"

                sh "sed -i 's|APP_NAME|${appName}|g' ingress.yaml"

                sh "cat ingress.yaml"

                sh "sed -i 's|SVC_NAME|${svcId}|g' ingress.yaml"
                sh "kubectl apply -f ingress.yaml -n ${namespace}"

                echo "ingress ${appName} updated"
                //TODO remove previous deployment
            }else{
                error("[FAILURE] no service available with color ${appColor}")
            }
        }
    }
}

def removeOldDeployment(String namespace, String oldColor){
    stage ('remove'){

        script {
            deleteDeploy = input message: 'Delete old deployment',
              parameters: [choice(name: 'Delete previous deployment', choices: 'no\nyes', description: "Choose yes if you want to remove deployment tainted with color ${oldColor}")]
        }
        if (deleteDeploy == "yes") { 

            svcIdtoDelete = sh (
                            script: "kubectl get svc -n ${namespace} -l color=${oldColor},name=${appName} | awk 'FNR==2{print \$1}'",
                            returnStdout: true
                        ).trim()

            if (svcIdtoDelete){

                //checking that the service is not exposed
                exposedSvcId = sh (
                                    script: "kubectl get ingress -n ${namespace} ${appName} -o jsonpath=\"{.spec.rules[*].http.paths[*].backend.serviceName}\"",
                                    returnStdout: true
                                ).trim()

                if (svcIdtoDelete != exposedSvcId) {
                    //deleting old deployment
                    sh "helm delete --purge ${svcIdtoDelete}"

                    echo "old service deleted"

                }else{
                    error("[FAILURE] service to delete is exposed")
                }
            }else{
                echo "no service to delete with color ${oldColor}"
            }

        }
    }

}