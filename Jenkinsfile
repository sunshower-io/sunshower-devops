pipeline {
    agent any

    environment {
        VERSION_BASE = "1.0.0"
        DOCKER_CREDENTIALS = credentials("dockerhub")
    }


    stages {
        stage('build-docker') {
            steps {
                sh "docker login --username='${DOCKER_CREDENTIALS_USR}' --password=${DOCKER_CREDENTIALS_PSW}"
                sh "docker build -t 'sunshower-base' -f dockerfiles/base-image.docker ."
                sh "docker tag sunshower-base sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
                sh "docker push sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
            }
        }
    }
}