#!/bin/bash

if [ ${#NAMESPACE} -eq 0 ];
then
read -p "Enter namespace[default]: " NAMESPACE
fi

NAMESPACE=${NAMESPACE:-default}


if [ ${#REGISTRY_ENDPOINT} -eq 0 ];
then
read -p "Enter private registry endpoint: " REGISTRY_ENDPOINT
fi

if [ ${#REGISTRY_USERNAME} -eq 0 ];
then
read -p "Enter docker login: " REGISTRY_USERNAME
fi

if [ ${#REGISTRY_PASSWORD} -eq 0 ];
then
read -s -p "Enter docker password: " REGISTRY_PASSWORD
echo ""
fi


kubectl create secret docker-registry regcred -n $NAMESPACE --docker-server=$REGISTRY_ENDPOINT --docker-username=$REGISTRY_USERNAME --docker-password=$REGISTRY_PASSWORD

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}' -n ${NAMESPACE}