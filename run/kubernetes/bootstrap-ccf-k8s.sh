#!/usr/bin/env bash

kubectl create ns ccf
kubectl create -f ./services/ccf-consul.json
kubectl create -f ./services/ccf-consul-srv.json

echo "***********************************************************************"
echo "****** NOW PLEASE CONFIGURE YOUR SETTINGS IN cf_parameters FILE *******"
echo "******           THEN RUN deploy-ccf-k8s.sh                     *******"
echo "***********************************************************************"
