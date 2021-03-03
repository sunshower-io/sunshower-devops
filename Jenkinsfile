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


    environment {
        MVN_REPO = credentials('artifacts-credentials')
    }
    node(POD_LABEL) {
        stage('check out project') {
            git(
                    branch: "**",
                    url: 'git@github.com:sunshower-io/sunshower-devops'
            )
        }
        stage('Get a Maven project') {
            container('maven') {
                stage('Build a Maven project') {
                    sh "ls -la"
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
