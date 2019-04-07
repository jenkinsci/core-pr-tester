/* Only keep the 10 most recent builds. */
properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', daysToKeepStr: '30']]])
timeout(time: 30, unit: 'MINUTES') {
    timestamps {
        node('docker') {
            stage('Checkout') {
                checkout scm
            }

            stage('Build') {
                sh 'docker build -t jenkins/core-pr-tester-pr .'
            }

            stage('Test image: standard use') {
                sh 'docker run --rm -e ID=2831 -p 8080:8080 -e DO_BUILD=no jenkins/core-pr-tester'
            }

        }
    }
}

