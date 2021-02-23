#!/bin/bash

while ! nc -z "$1"."$2" "$3" && ! nc -z "$1" "$3"; do
  echo "Couldn't reach either $1 or $1.$2.  Trying again"
  sleep 2
done
