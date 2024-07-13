#!/bin/bash

install_helm() {
    if ! command -v helm &> /dev/null; then
        echo "helm not found. Installing it now."
        if [ "$OS" = "Mac" ]; then
            brew install helm
        elif [ "$OS" = "Linux" ]; then
            curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        fi
    fi
    helm version
}
