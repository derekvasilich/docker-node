#!/bin/sh
set e+x

TAG=derekvasilich/docker-node:latest

echo "Building $TAG"
docker build -t $TAG .

echo "Do you wish to push the image (Y/n)?"
read PUSH
if [[ "$PUSH" == "Y" ]]
then
    echo "Pushing $TAG"
    docker push $TAG
fi