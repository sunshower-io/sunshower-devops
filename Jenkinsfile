pipeline {
    agent any

    environment {
        VERSION_BASE = "1.0.0"
        DOCKER_CREDENTIALS = credentials("dockerhub")
    }


    stages {
        stage('build-docker') {
            steps {
                sh "echo ${DOCKER_CREDENTIALS_USR}"
                sh "docker build -t 'sunshower-base' -f dockerfiles/base-image.docker ."
                sh "docker tag sunshower-base sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
                sh "docker push sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
            }
        }
    }
}