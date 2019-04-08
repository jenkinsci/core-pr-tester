/* Only keep the 10 most recent builds. */
properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', daysToKeepStr: '30']]])

def testedImageName='jenkins/core-pr-tester-pr'

timeout(time: 30, unit: 'MINUTES') {
    timestamps {
        node('docker') {
            stage('Checkout') {
                checkout scm
            }

            stage('Build') {
                sh "docker build -t $testedImageName ."
            }

            stage('Test image: standard use') {
                sh "docker run --rm -e ID=2831 -p 8080:8080 -e DO_BUILD=no $testedImageName"
            }

            // using stable-2.150 as expected to not change (and not break CI unexpectedly)
            stage('Test image: merge with branch') {
                sh "docker run --rm -e ID=2831 -e MERGE_WITH=stable-2.150 -p 8080:8080 -e DO_BUILD=no $testedImageName"
            }

        }
    }
}

