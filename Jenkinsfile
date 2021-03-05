
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

        stage('configure github credentials') {
            when {
                branch "master"
            }

            steps {
                container("maven") {
                    /**
                     * Configure GitHub username
                     */

                    sh """
                        git config --global user.name "${GITHUB_USR}"
                    """

                    /**
                     * Configure GitHub password
                     */
                    sh """
                        git config --global user.password "${GITHUB_PSW}"
                    """

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
                       git remote add origin https://github.com/sunshower-io/sunshower-devops 
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


                    /**
                     * prepare maven release
                     */
                    sh """
                        mvn -B release:prepare \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """

                    /**
                     * perform maven release
                     */
                    sh """
                        mvn -B release:prepare \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """
                }
            }
        }
    }
}