#!/bin/bash -eu

source ./scripts/set-version.sh

parse_version $1

mvn clean install -f sunshower-env/pom.xml -Denv.version=${VERSION}
mvn versions:set -DnewVersion=${VERSION} -f sunshower-env/pom.xml -Denv.version=${VERSION}
mvn clean install -f sunshower-env/parent/pom.xml -Denv.version=${VERSION}
mvn versions:set -DnewVersion=${VERSION} -f sunshower-env/parent/pom.xml -Denv.version=${VERSION}
mvn clean install deploy -f sunshower-env/pom.xml -Denv.version=${VERSION}
mvn clean install deploy -f sunshower-env/parent/pom.xml -Denv.version=${VERSION}
