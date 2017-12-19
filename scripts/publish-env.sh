#!/bin/bash -eu

source ./scripts/set-version.sh

parse_version $1

mvn clean install -f sunshower-env/pom.xml
mvn versions:set -DnewVersion=${VERSION} -f sunshower-env/pom.xml
mvn clean install -f sunsower-env/parent/pom.xml
mvn versions:set -DnewVersion=${VERSION} -f sunshower-env/parent/pom.xml
mvn clean install deploy -f sunshower-env/pom.xml
mvn clean install deploy -f sunshower-env/parent/pom.xml
