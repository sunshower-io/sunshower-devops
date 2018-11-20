pipeline {
    environment {
        MVN_REPO = credentials('artifacts-credentials')
        GITHUB = credentials('github-build-credentials')
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
                CURRENT_VERSION = readMavenPom(file: 'sunshower-env/pom.xml').getVersion()
            }
            when {
                branch 'master'
                expression {
                    env.SKIP_BUILD == "false"
                }
            }

            stages {
                stage('Build and Deploy Release POMs') {


                    steps {
                        /**
                         * Extract Environment Variables
                         */
                        extractVersions(version: env.CURRENT_VERSION)

                        /**
                         * Update Aggregator Versions
                         */
                        sh 'mvn versions:set -DnewVersion=$NEXT_VERSION -f sunshower-env/pom.xml -P sunshower'
                        sh 'mvn versions:set -DnewVersion=$NEXT_VERSION -f sunshower-env/parent/pom.xml -P sunshower'

                        /**
                         * Configure Git
                         */
                        sh "git config user.name '$GITHUB_USR'"
                        sh "git config user.email '${GITHUB_USR}@sunshower.io'"

                        /**
                         * Deploy parent and env
                         */
                        sh """
                            mvn clean install deploy \
                            -f sunshower-env/pom.xml \
                            -s sunshower-env/settings/settings.xml -P sunshower
                        """

                        sh """
                            mvn clean install deploy \
                            -f sunshower-env/parent/pom.xml \
                            -s sunshower-env/settings/settings.xml -P sunshower
                        """

                        /**
                         * Tag build
                         */
                        sh "git tag -af v${env.NEXT_VERSION} -m 'Releasing ${env.NEXT_VERSION} [skip-build]'"


                        /**
                         * Update remote
                         */
                        sh "git remote set-url origin https://${GITHUB_USR}:${GITHUB_PSW}@github.com/sunshower-io/sunshower-devops"

                        /**
                         * Push tag
                         */
                        sh "git push origin v${env.NEXT_VERSION}"

                        /**
                         * Update to snapshot versions
                         */
                        sh 'mvn versions:set -DnewVersion=$NEXT_SNAPSHOT -f sunshower-env/pom.xml'
                        sh 'mvn versions:set -DnewVersion=$NEXT_SNAPSHOT -f sunshower-env/parent/pom.xml'

                        /**
                         * Rebuild and deploy snapshots
                         */

                        sh """
                            mvn clean install deploy \
                            -f sunshower-env \
                            -s sunshower-env/settings/settings.xml -P sunshower
                        """

                        sh """
                            mvn clean install deploy \
                            -f sunshower-env/parent \
                            -s sunshower-env/settings/settings.xml -P sunshower
                        """

                        /**
                         * Commit snapshots back to master and skip build
                         */
                        sh "git commit -am 'Releasing ${env.NEXT_VERSION} [skip-build]'"
                        sh "git push -u origin HEAD:master"

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

