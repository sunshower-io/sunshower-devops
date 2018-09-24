pipeline {
    environment {
        MVN_REPO = credentials('artifacts')
    }
    agent {
        docker {
            image 'sunshower/sunshower-base:1.0.0'
        }
    }

    stages {
        stage('Check Commit Message for Skip Condition') {
            steps {
                skipRelease action: 'check', forceAbort: false
            }
        }
        stage('POMs') {

            when {
                expression {
                    env.SKIP_BUILD == "true"
                }
            }

            stages {
                stage('Build and Deploy Snapshot POMs') {
                    steps {
                        sh """
                        mvn clean install deploy \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """
                    }
                }
            }
        }
    }

    post {
        always {
            skipRelease action: 'postProcess'
        }
    }
}

//pipeline {
//    agent any
//
//    environment {
//        VERSION_BASE = "1.0.0"
//        MVN_REPO = credentials('artifacts')
//        DOCKER_CREDENTIALS = credentials("dockerhub")
//        GITHUB_CREDENTIALS = credentials("Build")
//        MAVEN_PROFILE="sunshower"
//        BN=UUID.randomUUID()
//    }
//
//
//    stages {
//        stage('build-docker') {
//            steps {
//                sh """
//                        #!/bin/bash -eu
//                        docker build -t "sunshower-base-${BN}" -f dockerfiles/base-image.docker .
//                        docker tag sunshower-base-${BN} sunshower/sunshower-base:1.0.0
//                        docker push sunshower/sunshower-base:1.0.0
//                        docker build -t sunshower-env-$BN -f dockerfiles/build-env.docker .
//                        docker run -e GPG_PASSPHRASE=p1llar5-0f-autumn \
//                            -e MVN_REPO_USERNAME=${MVN_REPO_USR} \
//                            -e MVN_REPO_PASSWORD=${MVN_REPO_PSW} \
//                            -e GITHUB_USERNAME=${GITHUB_CREDENTIALS_USR} \
//                            -e GITHUB_PASSWORD=${GITHUB_CREDENTIALS_PSW} \
//                            -e BRANCH_NAME=${env.BRANCH_NAME} \
//                            -e BUILD_ID=$BN \
//                            -e MAVEN_PROFILE="sunshower" \
//                            --rm --name "sunshower-env-$BN" sunshower-env-$BN
//"""
//            }
//        }
//    }
//}