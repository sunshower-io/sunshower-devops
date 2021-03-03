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
        stage('Get a Maven project') {
            git url: 'https://github.com/sunshower-io/sunshower-devops'
            container('maven') {
                stage('Build a Maven project') {
                    sh "ls -la"
                    sh 'mvn clean install -f sunshower-env'
                }
            }
        }
    }
}
