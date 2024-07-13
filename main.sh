#!/bin/bash

set -e

# Load utility scripts
source scripts/detect_os.sh
source scripts/start_docker_macos.sh
source scripts/install_kubectl.sh
source scripts/install_helm.sh
source scripts/install_python_venv.sh
source scripts/install_ansible.sh
source scripts/start_minikube.sh
source scripts/create_namespace.sh
source scripts/deploy_traefik.sh
source scripts/clone_ansible_fabric.sh
source scripts/install_ansible_collection.sh
source scripts/deploy_bank_vaults.sh
source scripts/deploy_external_secrets.sh
source scripts/create_k8s_external_secret.sh
source scripts/create_inventory_file.sh
source scripts/create_playbook_file.sh
source scripts/run_ansible_playbook.sh

main() {
    detect_os
    if [ "$OS" = "Mac" ]; then
        start_docker_macos
    fi
    install_kubectl
    install_helm
    install_python_venv
    . hyperledger_venv/bin/activate
    install_ansible
    start_minikube
    create_namespace
    deploy_traefik
    clone_ansible_fabric
    install_ansible_collection
    deploy_bank_vaults
    deploy_external_secrets
    create_k8s_external_secret
    create_inventory_file
    create_playbook_file
    run_ansible_playbook

    # Deploy backend
    cd backend
    go build -o app
    kubectl create deployment backend --image=backend:latest
    kubectl expose deployment backend --type=LoadBalancer --port=8080
    cd ..

    # Deploy frontend
    cd frontend
    npm install
    npm run build
    kubectl create deployment frontend --image=frontend:latest
    kubectl expose deployment frontend --type=LoadBalancer --port=80
    cd ..

    # Check the status of the pods
    echo "Checking the status of the pods in the namespace oss-hlf-infra..."
    kubectl get pods -n oss-hlf-infra

    echo "If there are any issues, you can check the logs of the individual pods using:"
    echo "kubectl logs <pod-name> -n oss-hlf-infra"
}

# Execute the main function
main
