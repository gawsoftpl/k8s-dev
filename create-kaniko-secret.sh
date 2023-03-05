#!/usr/bin/env bash

if [ ${#DOCKER_PRIVATE_ENDPOINT} -eq 0 ];
then
read -p "Enter private registry endpoint: " DOCKER_PRIVATE_ENDPOINT
fi

if [ ${#DOCKER_PRIVATE_USERNAME} -eq 0 ];
then
read -p "Enter docker login: " DOCKER_PRIVATE_USERNAME
fi

if [ ${#DOCKER_PRIVATE_PASSWORD} -eq 0 ];
then
read -s -p "Enter docker password: " DOCKER_PRIVATE_PASSWORD
echo ""
fi

if [ ${#DOCKER_DEV_ENDPOINT} -eq 0 ];
then
read -p "Enter private registry endpoint: " DOCKER_DEV_ENDPOINT
fi

if [ ${#DOCKER_DEV_USERNAME} -eq 0 ];
then
read -p "Enter docker login: " DOCKER_DEV_USERNAME
fi

if [ ${#DOCKER_DEV_PASSWORD} -eq 0 ];
then
read -s -p "Enter docker password: " DOCKER_DEV_PASSWORD
echo ""
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
stringData:
  config.json: |
    {
      "auths": {
        "$DOCKER_DEV_ENDPOINT": {
          "username": "$DOCKER_DEV_USERNAME",
          "password": "$DOCKER_DEV_PASSWORD"
        },

        "$DOCKER_PRIVATE_ENDPOINT": {
          "username": "$DOCKER_PRIVATE_USERNAME",
          "password": "$DOCKER_PRIVATE_PASSWORD"
          }
        }
    }

kind: Secret
metadata:
  name: kaniko-config
type: Opaque
EOF