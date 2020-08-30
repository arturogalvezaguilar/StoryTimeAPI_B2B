 
 pipeline {
   agent any

    stages{
stage('Pasos'){
    steps{ 

        deleteDir()

        checkout([
          $class: 'GitSCM',
          branches: scm.branches,
          extensions: scm.extensions + [[$class: 'CheckoutOption', timeout: 60],
          [$class: 'CloneOption', reference: '', timeout: 60]],
          userRemoteConfigs: scm.userRemoteConfigs
        ])

        stash name: 'nodejs', includes: "src/aws-lambda-nodejs/**/*"
        stash name: 'deployment', includes: "deployment/**/*"
        stash name: 'client.api.tests', includes: "src/client-api-tests/**/*"
        stash name: 'python', includes: "src/aws-lambda-python/**/*"

      }
    }
     
     stage('Build') { 
      steps{
          deleteDir()
          unstash 'nodejs'
          sh "cd src/aws-lambda-nodejs && npm install && npm run build"
          sh "cd src/aws-lambda-nodejs && rm -r node_modules && npm install --production"
          zip zipFile: 'kantoo.api.nodejs.zip', archive: false, dir: 'src/aws-lambda-nodejs'
          archiveArtifacts artifacts: '*.zip', fingerprint: true
          stash name: 'nodejs_dist', includes: "kantoo.api.nodejs.zip"
      }
        } 
     
   
 
 
  stage('Terraform') {
    steps('Pasos') { 
        deleteDir()

        unstash 'nodejs_dist'
        unstash 'deployment'
        unstash 'python'

        unzip zipFile: 'kantoo.api.nodejs.zip', dir: 'src/aws-lambda-nodejs', quiet: true
            sh 'whoami'
        
            sh 'cd ./deployment && sudo chmod u+x deploy.sh && ./deploy.sh'
           
      }
  } 
        
    }
     
 }

 
