#!/bin/bash

deploy_bank_vaults() {
    kubectl create namespace vault
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm repo update
    helm install vault-operator banzaicloud-stable/vault-operator --namespace vault
    helm install vault banzaicloud-stable/vault --namespace vault

    # Wait for Vault Operator and Vault to be ready
    kubectl rollout status deployment/vault-operator -n vault
    kubectl rollout status statefulset/vault -n vault

    echo "Waiting for Vault to be ready..."
    until kubectl get pods -n vault -l app.kubernetes.io/name=vault -o jsonpath="{.items[0].status.containerStatuses[0].ready}" | grep -q true; do
        echo "Waiting for Vault Pod to be ready..."
        sleep 5
    done

    echo "Vault is ready. Initializing and unsealing Vault..."
    kubectl exec -n vault -it vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > vault-init.json
    VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[0]" vault-init.json)
    VAULT_ROOT_TOKEN=$(jq -r ".root_token" vault-init.json)
    kubectl exec -n vault -it vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
    kubectl exec -n vault -it vault-0 -- vault login $VAULT_ROOT_TOKEN

    # Enable KV secrets engine and store TLS secrets
    kubectl exec -n vault -it vault-0 -- vault secrets enable -path=secret kv-v2
    kubectl exec -n vault -it vault-0 – vault kv put secret/myfabric tls.key=@tls/tls.key tls.crt=@tls/tls.crt

    # Create a policy for accessing the secrets
    cat <<EOF > fabric-policy.hcl
    capabilities = [“read”]
}
EOF
kubectl cp fabric-policy.hcl vault/vault-0:/tmp/fabric-policy.hcl
kubectl exec -n vault -it vault-0 – vault policy write fabric-policy /tmp/fabric-policy.hcl

# Enable Kubernetes auth method and configure it
kubectl exec -n vault -it vault-0 -- vault auth enable kubernetes
kubectl exec -n vault -it vault-0 -- vault write auth/kubernetes/config \
    token_reviewer_jwt="$(kubectl get secret $(kubectl get serviceaccount default -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 --decode)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl exec -n vault -it vault-0 -- vault write auth/kubernetes/role/fabric-role \
    bound_service_account_names=default \
    bound_service_account_namespaces=oss-hlf-infra \
    policies=fabric-policy \
    ttl=24h
}

