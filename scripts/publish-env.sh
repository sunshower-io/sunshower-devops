#!/bin/bash -eu

source ./scripts/set-version.sh

parse_version $1

mvn clean install deploy -f sunshower-env/pom.xml
