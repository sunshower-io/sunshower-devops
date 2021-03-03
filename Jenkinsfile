
pipeline {
    agent {
        kubernetes {
            yamlFile 'deployments/agent/template.yaml'
        }
    }

    stages {
        stage('build env poms') {
            environment {
                MVN_REPO = credentials('artifacts-credentials')
                CURRENT_VERSION = readMavenPom(file: 'sunshower-env/pom.xml').getVersion()
            }

            steps {
                container('maven') {
                    sh 'mvn -version'
                    sh 'java -version'
                    sh 'env'
                }
            }
        }
    }
}