#!/bin/bash -eu


source ./scripts/set-version.sh

parse_version $1
#export GPG_TTY=$(tty)

#echo "$GPG_ASC" | base64 -d | gpg --batch --passphrase=$GPG_PASSPHRASE --allow-secret-key-import --import

#POM_VERSION=echo '${project.version}\n0\n' | mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate | grep '^VERSION'
echo "Using Maven Profile: ${MAVEN_PROFILE}"
echo "Using version: ${VERSION}"
mvn clean install deploy -f sunshower-env/pom.xml -P ${MAVEN_PROFILE}
mvn clean install deploy -f sunshower-env/parent/pom.xml -P ${MAVEN_PROFILE}
mvn clean install deploy -f sunshower-env/parent/pom.xml -P ${MAVEN_PROFILE}

echo "Next version: $NEXT_VERSION"
if [ "$IS_RELEASE" = "true" ]; then
    mvn versions:set -DnewVersion=$VERSION;
    mvn clean install deploy -f sunshower-env/pom.xml -P ${MAVEN_PROFILE};
    mvn versions:set -DnewVersion=$NEXT_VERSION;
    git commit -am "Releasing";
    git push origin master;
fi;