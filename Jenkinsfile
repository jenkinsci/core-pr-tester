/* Only keep the 10 most recent builds. */
properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', daysToKeepStr: '30']]])

timestamps {
    node('docker') {
        stage('Checkout') {
            checkout scm
        }

        stage('Build') {
            sh 'docker build -t jenkins/core-pr-tester-pr .'
        }

        stage('Test image') {
            // TODO
        }
    }
}


