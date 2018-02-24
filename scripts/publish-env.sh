#!/bin/bash -eu


source ./scripts/set-version.sh

parse_version $1
export GPG_TTY=$(tty)

echo "$GPG_ASC" | base64 -d | gpg --batch --passphrase=$GPG_PASSPHRASE --allow-secret-key-import --import 

#mvn clean install -f sunshower-env/pom.xml -Denv.version=${VERSION}
#mvn versions:set -DnewVersion=${VERSION} -f sunshower-env/pom.xml -Denv.version=${VERSION}
mvn clean install -f sunshower-env/parent/pom.xml 
#mvn versions:set -DnewVersion=${VERSION} -f sunshower-env/parent/pom.xml 
mvn clean install deploy  -Dgpg.passphrase=$GPG_PASSPHRASE -f sunshower-env/pom.xml 
mvn clean install deploy  -Dgpg.passphrase=$GPG_PASSPHRASE -f sunshower-env/parent/pom.xml 
