
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

        stage('release POMs') {
            when {
                branch "master"
            }
            steps {

                container('maven') {

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
                     * perform maven release
                     */
                    sh """
                        mvn -B release:prepare release:perform \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """
                }
            }
        }
    }
}