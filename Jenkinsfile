podTemplate(
        imagePullSecrets: ['regcred'],
        containers: [
                containerTemplate(
                        name: 'maven',
                        command: 'cat',
                        ttyEnabled: true,
                        image: 'artifacts.sunshower.cloud:5001/maven:3.6.3-openjdk-16-slim'
                ),
        ]) {


    node(POD_LABEL) {
        checkout scm
        environment {
            MVN_REPO = credentials('artifacts-credentials')
        }
        stage('Get a Maven project') {
            container('maven') {
                stage('Build a Maven project') {
                    sh "env"
                    sh """
                        mvn clean install deploy \
                        -f sunshower-env \
                        -s sunshower-env/settings/settings.xml
                    """
                }
            }
        }
    }
}
