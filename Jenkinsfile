pipeline {
    agent any

    environment {
        BUILD_VERSION = sh 'echo \'${project.version}\\n0\\n\' | mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate | grep \'^VERSION\''
    }


    stages {
        stage('build-docker') {
            steps {
                sh "docker build -t 'sunshower-base' -f dockerfiles/base-image.docker ."
                sh "echo ${BUILD_VERSION}"
//                sh "docker tag sunshower-base sunshower/sunshower-base:$"
            }
        }
    }
}