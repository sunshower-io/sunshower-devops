
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

                sh "env"
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
        stage('compute next release version') {
            when {
                branch 'master'
            }
            steps {
                container('maven') {
                    script {

                        segs = (env.CURRENT_VERSION - '-SNAPSHOT').split('\\.')
                        nextVersionPrefix = (segs[0..-2] << ++segs[-1]).join('.')
                        nextVersion = nextVersionPrefix + "-SNAPSHOT"

                        env.nextVersion = nextVersion
                        env.NEXT_VERSION_PREFIX = nextVersionPrefix
                    }
                    sh "env"
                }
            }
        }

        stage('configure github credentials') {
            when {
                branch "master"
            }

            steps {
                container("maven") {

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



                }
            }

        }

        stage('release POMs') {
            when {
                branch "master"
            }
            steps {

                container('maven') {

                    sh "env"

                }
            }
        }
    }
}