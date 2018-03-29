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
                // TODO
            }
        }

        
        stage('Package') {
            steps {
            	echo 'Creating resource pack'
                sh "mkdir -p output"
                zip "output/xwos.zip" true "src"
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
