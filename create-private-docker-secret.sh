#!/bin/bash

if [ ${#NAMESPACE} -eq 0 ];
then
read -p "Enter namespace[default]: " NAMESPACE
fi

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


kubectl create secret docker-registry regcred -n $NAMESPACE --docker-server=$DOCKER_PRIVATE_ENDPOINT --docker-username=$DOCKER_PRIVATE_USERNAME --docker-password=$DOCKER_PRIVATE_PASSWORD

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}' -n ${NAMESPACE}