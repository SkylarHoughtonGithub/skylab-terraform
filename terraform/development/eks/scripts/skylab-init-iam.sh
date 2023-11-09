#! /bin/bash

kubectl get cm aws-auth -n kube-system -o yaml >> ../manifests/bootstrap/aws-auth-live.yml
#TODO: Determine why aws-auth fails to report as created from terraform 
# update config map manifest with missing permissions then run ./skylab-create-iam.sh
