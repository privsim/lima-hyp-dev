#!/bin/bash

deploy_external_secrets() {
    helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
    helm repo update
    helm install kubernetes-external-secrets external-secrets/kubernetes-external-secrets --namespace kube-system
}
