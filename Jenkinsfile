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
                echo 'Executing selftest for 1.7'
                wrap([$class: 'Xvnc', useXauthority: true]) {
                	sh "chmod 755 selftest_17.sh && ./selftest_17.sh"
                }
                archiveArtifacts artifacts: 'bin/record_17.flv', fingerprint:true
                sh "ffmpeg -i bin/record_17.flv bin/record_17.mp4"
                archiveArtifacts artifacts: 'bin/record_17.mp4', fingerprint:true
                sh "mv bin/junit.xml bin/junit_17.xml"
                archiveArtifacts artifacts: 'bin/junit_17.xml', fingerprint:true
                
                echo 'Executing selftest for 1.8'
                wrap([$class: 'Xvnc', useXauthority: true]) {
                	sh "chmod 755 selftest_18.sh && ./selftest_18.sh"
                }
                archiveArtifacts artifacts: 'bin/record_18.flv', fingerprint:true
                sh "ffmpeg -i bin/record_18.flv bin/record_18.mp4"
                archiveArtifacts artifacts: 'bin/record_18.mp4', fingerprint:true
                sh "mv bin/junit.xml bin/junit_18.xml"
                archiveArtifacts artifacts: 'bin/junit_18.xml', fingerprint:true
                
                echo 'Parsing luaunit results'
                junit 'bin/junit_17.xml'
                junit 'bin/junit_18.xml'
            }
        }

        
        stage('Package') {
            steps {
            	echo 'Creating resource pack'
                sh "cd src && zip -9r ../bin/xwos.zip *"
                archiveArtifacts artifacts: 'bin/xwos.zip', fingerprint:true
                sh "java -cp lua-packager-0.0.1-SNAPSHOT.jar eu.xworlds.xwos.tools.luapkg.MkInstaller src/assets/computercraft/lua/rom bin/package.lua"
                archiveArtifacts artifacts: 'bin/package.lua', fingerprint:true
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying'
                sh "cp bin/package.lua /srv/ftp-mounts/xworlds/httpdocs/xwos/latest"
                sh "cp bin/xwos.zip /srv/ftp-mounts/xworlds/httpdocs/xwos/latest"
                sh "cp bin/record_17.mp4 /srv/ftp-mounts/xworlds/httpdocs/xwos/latest"
                sh "cp bin/record_18.mp4 /srv/ftp-mounts/xworlds/httpdocs/xwos/latest"
                sh "cp docs/*.html /srv/ftp-mounts/xworlds/httpdocs/xwos"
                sh "cp docs/*.css /srv/ftp-mounts/xworlds/httpdocs/xwos"
                sh "cp -r docs/img /srv/ftp-mounts/xworlds/httpdocs/xwos"
                // sh "cp -r docs/bootstrap /srv/ftp-mounts/xworlds/httpdocs/xwos"
                // sh "cp -r docs/dist /srv/ftp-mounts/xworlds/httpdocs/xwos"
                // sh "cp -r docs/plugins /srv/ftp-mounts/xworlds/httpdocs/xwos"
                sh "cp -r docs/manual/* /srv/ftp-mounts/xworlds/httpdocs/xwos/latest"
                sh "xsltproc -o /srv/ftp-mounts/xworlds/httpdocs/xwos/latest/junit_17.html junit.xslt bin/junit_17.xml"
                sh "xsltproc -o /srv/ftp-mounts/xworlds/httpdocs/xwos/latest/junit_18.html junit.xslt bin/junit_18.xml"
                sh "date \"+%Y-%m-%d %H:%M:%S\" > /srv/ftp-mounts/xworlds/httpdocs/xwos/parts_snapshot.html"
            }

        }

    }
}
