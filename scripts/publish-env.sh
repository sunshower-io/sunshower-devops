#!/bin/bash -eu

git remote -v

source ./scripts/set-version.sh

#export GPG_TTY=$(tty)

#echo "$GPG_ASC" | base64 -d | gpg --batch --passphrase=$GPG_PASSPHRASE --allow-secret-key-import --import

POM_VERSION=$(echo 'VERSION=${project.version}' | mvn -f sunshower-env/pom.xml org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate | grep '^VERSION' | cut -f2 -d= | cut -f1 -d "-")
echo "POM Version: ${POM_VERSION}"

C_VERSION=$(parse_version $POM_VERSION)
VERSION=$C_VERSION
NEXT_VERSION=$(increment_version $POM_VERSION)


echo "Using Maven Profile: ${MAVEN_PROFILE}"
echo "Using version: ${VERSION}"
echo "Next version: $NEXT_VERSION";

mvn clean install deploy -f sunshower-env/pom.xml -P ${MAVEN_PROFILE}
mvn clean install deploy -f sunshower-env/parent/pom.xml -P ${MAVEN_PROFILE}

release_env "sunshower-io" "sunshower-devops"

