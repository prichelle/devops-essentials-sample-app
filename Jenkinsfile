//Name of credential object in Jenkins
creds = "apic-apidev"
commitId = "001"

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
        var1 = "hello"
        deploy(creds, var1)  

    } catch(exe)
    {
        echo "${exe}"
        error("[FAILURE] Failed to publish ${product}")
    }
}    

def deploy(String creds, String var1) {
        //Login to Dev Server
        try {
            echo "Accept license"
        } catch(exe){
            echo "Failed to Login to ${server} with Status Code: ${exe}"
            throw exe                       
        }  
        
        stage ('Build') {
                echo 'Running build automation'
                echo "My branch is: ${env.BRANCH_NAME}"
                //COMMITID = sh (
          			//script: 'git log --abbrev-commit --pretty=oneline -1',
          			//returnStdout: true
        		//).trim()
                sh 'git log --abbrev-commit --pretty=oneline -1'
                //echo "commit id: ${COMMITID}"
                //currentBuild.result = "FAILURE"
        } 
        stage ('registry load') {
            echo 'Loading built image into registry'
        }
}


