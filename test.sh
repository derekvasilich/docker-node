#!/bin/sh

docker container run --rm --entrypoint '' ${IMAGE_NAME:-derekvasilic/docker-node} cat /etc/alpine-release
docker container run --rm --entrypoint '' ${IMAGE_NAME:-derekvasilich/docker-node} chromium-browser --version