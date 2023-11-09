#! /bin/bash
# source: https://nivogt.medium.com/iac-continuous-delivery-with-crossplane-and-argocd-how-to-automate-the-creation-of-aws-eks-1523ef0e0aa#8a89
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
sleep 5
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'


# Get first time creds
echo -e "\n"
echo "#####"
echo "first time admin creds"
echo ""
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo -e "\n"
echo "#####"
