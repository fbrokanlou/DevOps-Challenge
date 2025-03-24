#!/bin/bash

APP_NAME="consumer"

IMAGE_NAME=mydomain.local/devops-challenge/$APP_NAME:latest

/usr/bin/docker build -t $IMAGE_NAME .

# If using K3s, save the Docker image and import it to K3s
if command -v /usr/local/bin/k3s &> /dev/null; then
    echo "K3s detected. Importing image into K3s..."
    /usr/bin/docker save $IMAGE_NAME | /usr/local/bin/k3s ctr images import -
    /usr/local/bin/k3s crictl images list
else
    echo "K3s not detected. Skipping image import to K3s."
fi
