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
                sh "ffmpeg -i bin/record.flv bin/record.mp4"
                archiveArtifacts artifacts: 'bin/record.mp4', fingerprint:true
                junit 'bin/junit.xml'
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
                sh "cp bin/xwos.zip /srv/ftp-mounts/xworlds/httpdocs/xwos/latest"
                sh "cp bin/record.mp4 /srv/ftp-mounts/xworlds/httpdocs/xwos/latest"
                sh "cp docs/*.html /srv/ftp-mounts/xworlds/httpdocs/xwos"
                sh "cp docs/*.css /srv/ftp-mounts/xworlds/httpdocs/xwos"
                sh "cp -r docs/img /srv/ftp-mounts/xworlds/httpdocs/xwos"
                // sh "cp -r docs/bootstrap /srv/ftp-mounts/xworlds/httpdocs/xwos"
                // sh "cp -r docs/dist /srv/ftp-mounts/xworlds/httpdocs/xwos"
                // sh "cp -r docs/plugins /srv/ftp-mounts/xworlds/httpdocs/xwos"
                sh "cp -r docs/manual/* /srv/ftp-mounts/xworlds/httpdocs/xwos/latest"
                sh "xsltproc -o /srv/ftp-mounts/xworlds/httpdocs/xwos/latest/junit.html junit.xslt bin/junit.xml"
                sh "date \"+%Y-%m-%d %H:%M:%S\" > /srv/ftp-mounts/xworlds/httpdocs/xwos/parts_snapshot.html"
            }

        }

    }
}
