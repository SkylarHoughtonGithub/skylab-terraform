#! /bin/bash
PREFIX="kube-prometheus-stack-52-1-0"
# add prom helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# helm search repo prometheus-community
# source: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#install-helm-chart

kubectl create namespace monitoring
helm install $PREFIX prometheus-community/kube-prometheus-stack -n monitoring
# expected output
# NAME: kube-prometheus-stack-52-1-0
# LAST DEPLOYED: Tue Nov  7 11:18:47 2023
# NAMESPACE: monitoring
# STATUS: deployed
# REVISION: 1
# NOTES:
# kube-prometheus-stack has been installed. Check its status by running:
#   kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack-52-1-0"

#Expose Grafana externally
kubectl patch svc $PREFIX-grafana -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'

# Get first time creds
echo -e "\n"
echo "#####"
echo "first time creds"
echo ""
kubectl get secret $PREFIX-grafana -n monitoring -o jsonpath="{.data.admin-user}" | base64 -d
echo ""
kubectl get secret $PREFIX-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
echo -e "\n"
echo "#####"
