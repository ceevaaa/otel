#!/bin/bash

# create the cluster
eksctl create cluster -f cluster.yaml --kubeconfig kubeconfig

# add the nginx containers
kubectl apply -f nginx.yaml

# expose the nginx containers
kubectl expose deployment/my-nginx --port=80 --target-port=80 --name=my-nginx-service --type=LoadBalancer