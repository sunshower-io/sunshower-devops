#!/bin/bash -eu

docker build -t "sunshower-base" -f dockerfiles/base-image.docker .
docker tag sunshower-base sunshower/sunshower-base:1.0.0
docker push sunshower/sunshower-base:1.0.0
docker build -t sunshower-env -f dockerfiles/build-env.docker .
docker run -e MVN_REPO_USERNAME=myMavenRepo -e MVN_REPO_PASSWORD=lid-DOG-bin-123 -it --rm --name "sunshower-env" sunshower-env


