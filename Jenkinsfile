
pipeline {
    agent any

    stages {
        stage('build-docker') {
            steps {
                sh "docker build -t 'sunshower-base' -f dockerfiles/base-image.docker ."
            }
        }
    }
}