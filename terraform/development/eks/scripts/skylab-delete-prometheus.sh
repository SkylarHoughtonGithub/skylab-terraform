#! /bin/bash
PREFIX="kube-prometheus-stack-52-1-0"

#uninstall
helm uninstall $PREFIX -n monitoring
