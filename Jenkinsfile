
pipeline {
    agent {
        kubernetes {
            yamlFile 'deployments/agent/template.yaml'
        }
    }

    stages {

        stage('Checkout') {
            steps {
                scmSkip(deleteBuild: true, skipPattern: '.*\\[released\\].*')
            }

        }

        stage('build env poms') {
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