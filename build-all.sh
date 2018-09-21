#!/bin/bash -eu
BASE_64_PGP=$(echo "$GPG_PK" | base64 -w10000000000000)
docker build -t "sunshower-base" -f dockerfiles/base-image.docker .
docker tag sunshower-base sunshower/sunshower-base:1.0.0
docker push sunshower/sunshower-base:1.0.0
docker build -t sunshower-env -f dockerfiles/build-env.docker .
docker run -e GPG_PASSPHRASE=p1llar5-0f-autumn \
    -e MVN_REPO_USERNAME=admin \
    -e MVN_REPO_PASSWORD=p1llar5-0f-autumn \
    -e GPG_ASC=$BASE_64_PGP \
    -e MAVEN_PROFILE="sunshower" \
    --rm --name "sunshower-env" sunshower-env


