pipeline {
    agent {
        kubernetes {
            yamlFile 'deployments/agent/template.yaml'
        }
    }
    environment {

        /**
         * credentials for Artifactory
         */
        MVN_REPO = credentials('artifacts-credentials')


        /**
         * github credentials
         */
        GITHUB = credentials('github-build-credentials')

        /**
         * this just contains the build email address and name
         */
        GITHUB_USER = credentials("github-build-userinfo")

        /**
         * current version
         */
        CURRENT_VERSION = readMavenPom(file: 'sunshower-env/pom.xml').getVersion()
    }

    stages {

        stage('Checkout') {
            steps {
                scmSkip(deleteBuild: true, skipPattern: '.*\\[released\\].*')
            }

        }

        stage('build env poms') {

            steps {
                container('maven') {
                    sh """
                        mvn clean install deploy \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """
                }
            }
        }

        /**
         * we could probably eventually handle this via plugin, but the process is:
         *
         * Upon merge to master:
         *
         * 1. Increment the version number
         * 2. Update the version-number in the POM files
         * 3. Rebuild the Maven/Gradle projects
         * 4. Upon success, increment to next snapshot
         * 5. Upon failure, fail
         * 6. Push next snapshot to master
         */
        stage('deploy master snapshot') {
            when {
                branch 'master'
            }
            steps {
                container('maven') {
                    script {
                        segs = (env.CURRENT_VERSION - '-SNAPSHOT').split('\\.')
                        env.NEXT_VERSION = "${segs.join('.')}-${env.BUILD_NUMBER}-SNAPSHOT"
                    }

                    /**
                     * increment versions
                     */
                    sh """
                        mvn -f sunshower-env \
                        versions:set -DnewVersion="${env.NEXT_VERSION}"
                    """
                    /**
                     * deploy
                     */
                    sh """
                        mvn clean install deploy \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """
                }
            }
        }


        stage("release component") {
            when {
                expression {
                    env.GIT_BRANCH == "release/${env.CURRENT_VERSION}"
                }
            }

            steps {
                container('maven') {

                    script {
                        /**
                         * strip the leading "release/" prefix
                         */
                        env.TAG_NAME = env.GIT_BRANCH - "release/"

                        /**
                         * compute the next versions:
                         *
                         * RELEASED_VERSION is the version that we're
                         * 1. building
                         * 2. deploying
                         * 3. tagging
                         *
                         * NEXT_VERSION is the version that main will be incremented to
                         *
                         * So, if CURRENT_VERSION = 1.0.0-SNAPSHOT,
                         * then RELEASED_VERSION = 1.0.0.Final
                         * and NEXT_VERSION = 1.0.1-SNAPSHOT
                         */
                        version = env.CURRENT_VERSION


                        segs = (version - '-SNAPSHOT')
                                .split('\\.')
                                .collect { i ->
                                    i as int
                                }

                        releasedVersion = (segs[0..-2] << ++segs[-1]).join('.')
                        nextVersion = releasedVersion + "-SNAPSHOT"

                        env.NEXT_VERSION = nextVersion
                        env.RELEASED_VERSION = "${releasedVersion}.Final"
                    }


                    /**
                     * configure github email address
                     */
                    sh """
                        git config --global user.email "${GITHUB_USER_USR}"
                    """

                    /**
                     * configure
                     */
                    sh """
                        git config --global user.name "${GITHUB_USER_PSW}"
                    """

                    sh """
                        mkdir -p ~/.ssh
                    """

                    sh """
                        ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
                    """

                    sh """
                        git remote set-url --push origin https://${GITHUB_PSW}@github.com/sunshower-io/sunshower-devops
                    """

                    sh """
                        mvn versions:set \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml \
                        -DnewVersion="${env.RELEASED_VERSION}"
                    """

                    sh """
                        mvn clean install deploy \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """

                    sh """
                        git tag "v${env.RELEASED_VERSION}" \
                        -m "[released] Tagging: ${env.RELEASED_VERSION} (from ${env.TAG_NAME})"
                    """

                    sh """
                        git push origin "v${env.RELEASED_VERSION}"
                    """

                    sh """
                        mvn versions:set \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml \
                        -DnewVersion="${env.NEXT_VERSION}"
                    """

                    sh """
                        mvn clean install deploy \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """


                    sh """
                        git commit -am "[released] ${env.TAG_NAME} -> ${env.RELEASED_VERSION}"
                    """

                    sh """
                        git checkout -b master
                    """


                    sh """
                        git push -u origin master
                    """
                }
            }

        }
    }
}