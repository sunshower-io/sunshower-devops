#!/usr/bin/zsh

docker build -f \
  ./dockerfiles/base-image.docker . \
  -t artifacts.sunshower.cloud:6000/sunshower-base:latest


docker push artifacts.sunshower.cloud:6000/sunshower-base:latest