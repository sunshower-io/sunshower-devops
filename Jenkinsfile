pipeline {
    agent any

    environment {
        VERSION_BASE = "1.0.0"
        MVN_REPO = credentials('ARTIFACTS_CREDENTIALS')
        DOCKER_CREDENTIALS = credentials("dockerhub")
        MAVEN_PROFILE="sunshower"
//        MAVEN_REPOSITORY_URL = "https://oss.sonatype.org/content/repositories/snapshots"
    }


    stages {
        stage('build-docker') {
            steps {
                sh "docker login --username='${DOCKER_CREDENTIALS_USR}' --password=${DOCKER_CREDENTIALS_PSW}"
                sh "docker build -t 'sunshower-base' -f dockerfiles/base-image.docker ."
                sh "docker tag sunshower-base sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
                sh "docker push sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
                sh "docker build -t 'sunshower-env' -f dockerfiles/build-env.docker ."
                sh "docker run " +
                        "-e MVN_REPO_USERNAME=${MVN_REPO_USR} " +
                        "-e MVN_REPO_PASSWORD=${MVN_REPO_PSW} " +
                        "-e MAVEN_PROFILE=${MAVEN_PROFILE} " +
                        "-it --rm --name 'sunshower-env' 'sunshower-env'"
            }
        }
    }
}