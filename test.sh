#!/bin/sh
IMAGE=derekvasilich/docker-node

# CHROME_OPTS=(--user-data-dir=/tmp
#     --enable-automation
#     --no-default-browser-check
#     --no-first-run
#     --disable-default-apps
#     --disable-popup-blocking
#     --disable-translate
#     --disable-background-timer-throttling
#     --disable-renderer-backgrounding
#     --disable-device-discovery-notifications
#     http://localhost:9876/?id=25311182
#     --headless
#     --disable-gpu
#     --disable-dev-shm-usage
#     --remote-debugging-port=9222
#     --no-sandbox)

docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} dpkg --print-architecture
docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} cat /etc/debian_version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} google-chrome --version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} node --version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} npm --version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} yarn --version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} git --version
docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} whoami
docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} pwd

# docker container run --rm --entrypoint '' ${IMAGE_NAME:-$IMAGE} google-chrome ${CHROME_OPTS[@]}

# Run Snyk security scan
#   npm i -g snyk
#   snyk auth
echo "Do you wish to perform a security scan (Y/n)?"
read SCAN
if [[ "$SCAN" == "Y" ]]
then
    snyk container test $IMAGE --file=Dockerfile
fi