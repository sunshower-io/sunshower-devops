
pipeline {
    agent {
        kubernetes {
            yamlFile 'deployments/agent/template.yaml'
        }
    }

    stages {
        steps {
            container('maven') {
                sh 'mvn -version'
                sh 'java -version'
                sh 'echo HELLO'
            }
        }
    }
}