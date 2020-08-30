def getWorkspace() {
    pwd().replace("%2F", "_")
}

environment {
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    AWS_DEFAULT_REGION = credentials('AWS_DEFAULT_REGION')
}
/**/
try {
 pipeline {
   agent any

    stages{
stage('Pasos'){
    steps{
   
      ws(getWorkspace()) {
        workspace = pwd()

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
    }
 

  stage('Build') {

     parallel(
      'nodejs': {
        node('node') {
          deleteDir()

          unstash 'nodejs'
          sh "cd src/aws-lambda-nodejs && npm install && npm run build"
          sh "cd src/aws-lambda-nodejs && rm -r node_modules && npm install --production"


          zip zipFile: 'kantoo.api.nodejs.zip', archive: false, dir: 'src/aws-lambda-nodejs'

          archiveArtifacts artifacts: '*.zip', fingerprint: true

          stash name: 'nodejs_dist', includes: "kantoo.api.nodejs.zip"
        }
      }
    )
  }

  stage('Terraform') {
    node('docker') {
      wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm', 'defaultFg': 1, 'defaultBg': 2]) {
        deleteDir()

        unstash 'nodejs_dist'
        unstash 'deployment'
        unstash 'python'

        unzip zipFile: 'kantoo.api.nodejs.zip', dir: 'src/aws-lambda-nodejs', quiet: true

        docker
          .image('hashicorp/terraform')
          .withRun() { c->
            sh 'cd ./deployment && sudo chmod u+x deploy.sh && ./deploy.sh'
          }
      }
    }
  }
        
    }
     
 }

  /*slackSend channel: 'kantoo-ci', message: "*Build success* ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>) 🚀", color: "good"*/
  currentBuild.result = 'SUCCESS'
} catch (e) {
  /*slackSend channel: 'kantoo-ci', message: "*Build failed* ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)", color: "danger"*/
  currentBuild.result = 'FAILURE'
  throw e
} finally {
  /*if (env.TF_VAR_env_name == "prod" || env.TF_VAR_env_name == "qa") {
    node {
      println currentBuild.result  // this prints null
      step([$class: 'Mailer', notifyEveryUnstableBuild: true, recipients: 'denysenkoa@mydigicode.com, uri.z@la-mark.com', sendToIndividuals: true])
    }
  }*/
}
