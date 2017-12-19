#!/bin/bash -eu

source ./scripts/set-version.sh

parse_version $1

mvn versions:set -DnewVersion=${VERSION} -f sunshower-env/pom.xml
mvn clean install deploy -f sunshower-env/pom.xml
