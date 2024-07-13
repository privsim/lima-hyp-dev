#!/bin/bash

create_k8s_external_secret() {
    cat <<EOF | kubectl apply -f -
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: fabric-tls-secret
  namespace: oss-hlf-infra
spec:
  backendType: vault
  vaultMountPoint: "kubernetes"
  vaultRole: "fabric-role"
  secretDescriptor:
    - key: "secret/data/myfabric"
      property: "tls.key"
      name: "tls.key"
    - key: "secret/data/myfabric"
      property: "tls.crt"
      name: "tls.crt"
EOF
}
