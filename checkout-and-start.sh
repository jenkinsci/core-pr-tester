#!/bin/bash

set -eou pipefail

echo "fetching PR-$ID"
git fetch origin pull/$ID/head:TESTING-BRANCH
git checkout TESTING-BRANCH

echo "Building $( git rev-parse HEAD )"

mvn -V -pl war --also-make clean package -DskipTests -Dmaven.test.skip=true

echo "Starting Jenkins"
java -jar war/target/jenkins.war
