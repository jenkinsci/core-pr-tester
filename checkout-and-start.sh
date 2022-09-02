#!/bin/bash

set -eou pipefail

echo "Updating origin"
git fetch origin
git reset --hard origin/master

echo "fetching PR-$ID"
git fetch origin pull/$ID/head:TESTING-BRANCH
git checkout TESTING-BRANCH

if [[ ${MERGE_WITH:-} != "" ]]; then
    echo "Non interactive merge with specified branch '$MERGE_WITH' -- will fail if conflict"
    git merge --no-edit origin/$MERGE_WITH
else
    echo "No merge requested"
fi

echo "Building $( git rev-parse HEAD )"

if [[ ${DO_BUILD:-yes} == "no" ]]; then ## Useful for testing
    echo "Stop before build requested, exiting"
    exit 0
fi

mvn --no-transfer-progress -V -pl war --also-make clean package -DskipTests -Dmaven.test.skip=true -P quick-build

if [[ -n ${JENKINS_HOME-} ]]; then
    export JENKINS_HOME=$JENKINS_HOME
    echo "Jenkins home directory changed to $JENKINS_HOME"
else
    echo "Using default home directory"
fi

echo "Starting Jenkins"
java -jar war/target/jenkins.war
