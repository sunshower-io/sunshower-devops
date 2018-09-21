#!/bin/bash -eu


source ./scripts/set-version.sh

#export GPG_TTY=$(tty)

#echo "$GPG_ASC" | base64 -d | gpg --batch --passphrase=$GPG_PASSPHRASE --allow-secret-key-import --import

POM_VERSION=$(echo 'VERSION=${project.version}' | mvn -f sunshower-env/pom.xml org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate | grep '^VERSION' | cut -f2 -d= | cut -f1 -d "-")
echo "POM Version: ${POM_VERSION}"

VERSION=$(parse_version $POM_VERSION)
echo "Using Maven Profile: ${MAVEN_PROFILE}"
echo "Using version: ${VERSION}"
mvn clean install deploy -f sunshower-env/pom.xml -P ${MAVEN_PROFILE}
mvn clean install deploy -f sunshower-env/parent/pom.xml -P ${MAVEN_PROFILE}

if [ "$IS_RELEASE" = "true" ]; then
    NEXT_VERSION=$(increment_version $NEXT_VERSION);
    echo "Setting version: $VERSION -> $NEXT_VERSION"
    mvn versions:set -f sunshower-env/pom.xml -DnewVersion=$VERSION;
    mvn versions:set -f sunshower-env/parent/pom.xml -DnewVersion=$VERSION;
    mvn clean install deploy -f sunshower-env/pom.xml -P ${MAVEN_PROFILE};
    mvn clean install deploy -f sunshower-env/parent/pom.xml -P ${MAVEN_PROFILE};
    mvn versions:set -f sunshower-env/pom.xml -DnewVersion=$NEXT_VERSION -P ${MAVEN_PROFILE};
    mvn versions:set -f sunshower-env/parent/pom.xml -DnewVersion="${NEXT_VERSION}-SNAPSHOT" -P ${MAVEN_PROFILE};
fi;