pipeline {
    agent any

    environment {
        VERSION_BASE = "1.0.0"
    }


    stages {
        stage('build-docker') {
            steps {
                sh "docker build -t 'sunshower-base' -f dockerfiles/base-image.docker ."
                sh "docker tag sunshower-base sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
                sh "docker push sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
            }
        }
    }
}