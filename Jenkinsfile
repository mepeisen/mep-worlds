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
                wrap([$class: 'Xvnc', useXauthority: true]) {
                	sh "chmod 755 selftest.sh && ./selftest.sh"
                }
                archiveArtifacts artifacts: 'bin/record.flv', fingerprint:true
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
