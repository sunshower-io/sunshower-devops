podTemplate(
        imagePullSecrets: ['regcred'],
        containers: [
                containerTemplate(
                        name: 'maven',
                        command: 'cat',
                        ttyEnabled: true,
                        image: 'artifacts.sunshower.cloud:5001/maven:3.6.3-openjdk-16-slim'
                ),
        ],
        volumes: [
                hostPathVolume(
                        mountPath: '/var/run/docker.sock',
                        hostPath: '/var/run/docker.sock'
                )
        ]) {


    node(POD_LABEL) {
        stage('checkout repository') {
            checkout scm
        }

//        stage('skip if built') {
//            when {
//                not {
//                    changelog '.*^\\[released\\] .+$'
//                }
//            }
//        }
//
        stage('Publish Bills-of-material') {
            container('maven') {
                withCredentials([[
                                         $class          : 'UsernamePasswordMultiBinding',
                                         credentialsId   : 'artifacts-credentials',
                                         usernameVariable: 'MVN_REPO_USR',
                                         passwordVariable: 'MVN_REPO_PSW'
                                 ]]) {
                    sh """
                        mvn clean install deploy \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """
                }
            }
        }

        stage('Set Maven POM version') {
            container('maven') {
                environment {
                    CURRENT_VERSION = readMavenPom(file: 'sunshower-env/pom.xml').getVersion()
                }
                sh "env"
                sh "java -version"
                sh "echo ${env.CURRENT_VERSION}"
            }
        }
    }
}


pipeline {
    agent any
    stages {
        stage('test') {
            steps {
                echo "HELLO WORLD"
                sh "env"
            }
        }
    }
}
