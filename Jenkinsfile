/* Only keep the 10 most recent builds. */
properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', daysToKeepStr: '30']]])

def testedImageName='jenkins/core-pr-tester-pr'

timeout(time: 30, unit: 'MINUTES') {
    node('arm64docker') {
        stage('Checkout ARM') {
            checkout scm
        }

        stage('Build ARM') {
            sh """
            export DOCKER_CLI_EXPERIMENTAL="enabled"
            docker --version

            docker buildx create --use
            docker buildx build --load --tag $testedImageName --platform linux/arm64/v8 .
            """
        }

        stage('Test image: standard use ARM') {
            sh "docker run --rm -e ID=2831 -p 8080:8080 -e DO_BUILD=no $testedImageName"
        }



    }

    node('docker') {
        stage('Checkout AMD64') {
            checkout scm
        }

        stage('Build AMD64') {
            sh """
            export DOCKER_CLI_EXPERIMENTAL="enabled"
            docker --version

            docker run --rm arm64v8/alpine ls
            docker run --rm armhf/alpine ls

            docker buildx create --use
            docker buildx build --load --tag $testedImageName --platform linux/amd64 .
            """
        }

        stage('Test image: standard use AMD64') {
            sh "docker run --rm -e ID=2831 -p 8080:8080 -e DO_BUILD=no $testedImageName"
        }

        // TODO: enable this
        // Not easy to make this test stable over time
        // using stable-2.150 as expected to not change (and not break CI unexpectedly)
        // stage('Test image: merge with branch') {
        //     sh "docker run --rm -e ID=2831 -e MERGE_WITH=stable-2.150 -p 8080:8080 -e DO_BUILD=no $testedImageName"
        // }

    }
}

