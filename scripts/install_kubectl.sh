#!/bin/bash

install_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl not found. Installing it now."
        if [ "$OS" = "Mac" ]; then
            brew install kubectl
        elif [ "$OS" = "Linux" ]; then
            curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
            chmod +x ./kubectl
            sudo mv ./kubectl /usr/local/bin/kubectl
        fi
    fi
    kubectl version --client
}
