pipeline {
    agent any
    tools {
        maven 'maven3.5.0'
    }
    stages {
        stage('Initialization') {
            steps {
            	echo 'Preparing for build'
           	}
        }
        
        stage('Test') {
            steps {
                echo 'Executing selftest'
                sh "selftest.sh"
            }
        }

        
        stage('Package') {
            steps {
            	echo 'Creating resource pack'
                sh "cd src && zip -9r ../bin/xwos.zip *"
                archiveArtifacts artifacts: 'bin/xwos.zip', fingerprint:true
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying'
                // TODO
            }

        }

    }
}
