#! /bin/bash

#Bootstrap basic multi-az k8s cluster with networking components
kubectl apply -f manifests/bootstrap/aws-auth-live.yml
