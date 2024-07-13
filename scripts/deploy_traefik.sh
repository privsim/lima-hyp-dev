#!/bin/bash

deploy_traefik() {
    helm repo add traefik https://helm.traefik.io/traefik
    helm repo update
    helm install traefik traefik/traefik --namespace kube-system
}
