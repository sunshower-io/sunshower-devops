pipeline {
    environment {
        MVN_REPO = credentials('artifacts')
        GITHUB = credentials('Build')
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

        stage('Build and Deploy POM Snapshots') {
            steps {
                sh """
                        mvn clean install deploy \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """
            }
        }
        stage('POMs') {
            environment {
                CURRENT_VERSION = readMavenPom(file:'sunshower-env/pom.xml').getVersion()

            }
            when {
                expression {
                    env.SKIP_BUILD == "false"
                }
            }

            stages {
                stage('Build and Deploy Release POMs') {


                    steps {
                        extractVersions(version:env.CURRENT_VERSION)
                        sh 'mvn versions:set -DnewVersion=$NEXT_VERSION -f sunshower-env/pom.xml'
                        sh """
                            mvn clean install deploy \
                            -f sunshower-env \
                            -s sunshower-env/settings/settings.xml
                        """
//                        sh "git checkout -b master"
//                        sh "git tag -a v${env.NEXT_VERSION} -m 'Releasing ${env.NEXT_VERSION} [skip-build]'"
                        sh "git remote set-url origin https://${GITHUB_USR}:${GITHUB_PSW}@github.com/sunshower-io/sunshower-devops"
//                        sh "git push origin v${env.NEXT_VERSION}"
                        sh 'mvn versions:set -DnewVersion=$NEXT_SNAPSHOT -f sunshower-env/pom.xml'
                        sh """
                            mvn clean install deploy \
                            -f sunshower-env \
                            -s sunshower-env/settings/settings.xml
                        """
                        sh "git commit -am 'Releasing ${env.NEXT_VERSION} [skip-build]'"
                        sh 'git pull origin master'
                        sh "git push -u origin master"

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