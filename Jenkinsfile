
pipeline {
    agent {
        kubernetes {
            yamlFile 'deployments/agent/template.yaml'
        }
    }

    stages {
        stage('build env poms') {

            steps {
                container('maven') {
                    sh 'mvn -version'
                    sh 'java -version'
                    sh 'echo HELLO'
                }
            }
        }
    }
}