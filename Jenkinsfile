pipeline {
    agent any

    environment {
        VERSION_BASE = "1.0.0"
        MVN_REPO = credentials('artifacts')
        DOCKER_CREDENTIALS = credentials("dockerhub")
        MAVEN_PROFILE="sunshower"
        BN=UUID.randomUUID()
    }


    stages {
        stage('build-docker') {
            steps {
                println("PASSWORD: $MVN_REPO_PSW")
                println("USER: $MVN_REPO_USR")
                sh """
                        #!/bin/bash -eu
                        docker build -t "sunshower-base-${BN}" -f dockerfiles/base-image.docker .
                        docker tag sunshower-base-${BN} sunshower/sunshower-base:1.0.0
                        docker push sunshower/sunshower-base:1.0.0
                        docker build -t sunshower-env-$BN -f dockerfiles/build-env.docker .
                        docker run -e GPG_PASSPHRASE=p1llar5-0f-autumn \
                            -e MVN_REPO_USERNAME=${MVN_REPO_USR} \
                            -e MVN_REPO_PASSWORD=${MVN_REPO_PSW} \
                            -e BUILD_ID=$BN \
                            -e MAVEN_PROFILE="sunshower" \
                            --rm --name "sunshower-env-$BN" sunshower-env-$BN
                git commit -am "Releasing";
                git push origin master;
"""
            }
        }
    }
}