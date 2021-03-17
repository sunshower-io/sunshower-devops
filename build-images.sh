#!/usr/bin/zsh

docker build -f \
  ./dockerfiles/base-image.docker . \
  -t sunshowercloud/sunshower-base:latest


docker push sunshowercloud/sunshower-base:latest
