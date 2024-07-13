#!/bin/bash

start_minikube() {
    if [ "$OS" = "Mac" ]; then
        if ! command -v colima &> /dev/null; then
            echo "Colima not found. Installing it now."
            brew install colima
        fi
        colima start
        if ! command -v minikube &> /dev/null; then
            brew install minikube
        fi
    elif [ "$OS" = "Linux" ]; then
        curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        chmod +x minikube
        sudo mv minikube /usr/local/bin/
    fi
    minikube start --driver=docker --extra-config=kubelet.cgroup-driver=systemd
    kubectl config use-context minikube
}
