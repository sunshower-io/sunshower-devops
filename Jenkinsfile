
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
                MVN_REPO = credentials('artifacts-credentials')
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
        }
    }
}