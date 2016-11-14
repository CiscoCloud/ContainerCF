#!/usr/bin/env bash

echo "**** Opening a kubernetes port forward to the consul app ****"
sleep 3

kubectl --namespace=ccf port-forward `kubectl --namespace=ccf get po | grep ccf-consul | awk -F" " '{ print $1 }'` 8501:8500 &
sleep 2

echo "**** Populating Consul KV Store with CF Cluster Settings ****"
sleep 3

source ./cf_parameters
for key in "${!kv_array[@]}"
do
  value=${kv_array[$key]}
  curl -X PUT -d "$value" http://localhost:8501/v1/kv${key}
done

echo "**** Deploying CCF Components to Kubernetes ****"
sleep 3

kubectl --namespace=ccf create -f ./apps/postgres.json &
kubectl --namespace=ccf create -f ./apps/nats.json &
kubectl --namespace=ccf create -f ./apps/router.json &
kubectl --namespace=ccf create -f ./apps/hm9000.json &
kubectl --namespace=ccf create -f ./apps/uaa.json &
kubectl --namespace=ccf create -f ./apps/etcd.json &
kubectl --namespace=ccf create -f ./apps/consul.json &
kubectl --namespace=ccf create -f ./apps/clock.json &
kubectl --namespace=ccf create -f ./apps/api.json &
kubectl --namespace=ccf create -f ./apps/loggregator-trafficcontroller.json &
kubectl --namespace=ccf create -f ./apps/loggregator.json &
kubectl --namespace=ccf create -f ./apps/ha-proxy.json &

if $DIEGO_ENABLED == true; then
    echo "**** Deploying Diego ****"
    kubectl --namespace=ccf create -f ./apps/diego.json
    kubectl --namespace=ccf create -f ./apps/diego-cell.json
else
    echo "**** Deploying DEA ****"
    kubectl --namespace=ccf create -f ./apps/dea.json
fi

echo "**** FINISHED DEPLOYING CCF CONTAINERS TO KUBERNETES ****"
echo "**** You can see each component registered in the KV Store at http://localhost:8501 ****"
