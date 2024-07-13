#!/bin/bash

create_playbook_file() {
    cat <<EOF > install-oss.yml
---
- name: Deploy Hyperledger Fabric Open Source Operator and Custom Resource Definitions
  hosts: localhost
  vars:
    state: present
    target: k8s
    arch: amd64
    namespace: oss-hlf-infra
    wait_timeout: 3600
  roles:
    - hyperledger.fabric_ansible_collection.fabric_operator_crds

- name: Deploy Hyperledger Fabric Open Source Console
  hosts: localhost
  vars:
    state: present
    target: k8s
    arch: amd64
    namespace: oss-hlf-infra
    console_name: myfabric-console
    console_domain: myfabric.local
    console_email: admin@myfabric.local
    console_default_password: adminpw
    console_storage_class: standard
    console_tls_secret: myfabric-tls-secret
    wait_timeout: 3600
  roles:
    - hyperledger.fabric_ansible_collection.fabric_console
EOF
}
