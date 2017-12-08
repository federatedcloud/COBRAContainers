#!/bin/bash

REPO=cobra_matlab_nix
TAG=testing0
export COBRA_IMAGE="${REPO}:${TAG}"
docker build --build-arg nixuser=`whoami` -t $COBRA_IMAGE -f Dockerfile .
# docker build --pull --tag kurron/intellij-local:latest .
