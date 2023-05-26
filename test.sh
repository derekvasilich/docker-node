#!/bin/sh

docker container run --rm --entrypoint '' ${IMAGE_NAME:-derekvasilich/docker-node} cat /etc/alpine-release
docker container run --rm --entrypoint '' ${IMAGE_NAME:-derekvasilich/docker-node} chromium-browser --version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-derekvasilich/docker-node} node --version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-derekvasilich/docker-node} npm --version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-derekvasilich/docker-node} yarn --version