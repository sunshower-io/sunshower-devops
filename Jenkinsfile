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
                println("PASSWORD: $MVN_REPO_PSW")
                println("USER: $MVN_REPO_USR")
                sh """

#!/bin/bash -eu
//BASE_64_PGP=\$(echo "$GPG_PK" | base64 -w10000000000000)
docker build -t "sunshower-base" -f dockerfiles/base-image.docker .
docker tag sunshower-base sunshower/sunshower-base:1.0.0
docker push sunshower/sunshower-base:1.0.0
docker build -t sunshower-env -f dockerfiles/build-env.docker .
docker run -e GPG_PASSPHRASE=p1llar5-0f-autumn \
    -e MVN_REPO_USERNAME=admin \
    -e MVN_REPO_PASSWORD=p1llar5-0f-autumn \
    -e MAVEN_PROFILE="sunshower" \
    --rm --name "sunshower-env" sunshower-env


"""
//                sh "docker login --username='${DOCKER_CREDENTIALS_USR}' --password=${DOCKER_CREDENTIALS_PSW}"
//                sh "docker build -t 'sunshower-base' -f dockerfiles/base-image.docker ."
//                sh "docker tag sunshower-base sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
//                sh "docker push sunshower/sunshower-base:${VERSION_BASE}-SNAPSHOT"
//                sh "docker build -t 'sunshower-env' -f dockerfiles/build-env.docker ."
//                sh "docker run " +
//                        "-e MVN_REPO_USERNAME=${MVN_REPO_USR} " +
//                        "-e MVN_REPO_PASSWORD=${MVN_REPO_PSW} " +
//                        "-e MAVEN_PROFILE=${MAVEN_PROFILE} " +
//                        "--rm --name 'sunshower-env' 'sunshower-env'"
            }
        }
    }
}