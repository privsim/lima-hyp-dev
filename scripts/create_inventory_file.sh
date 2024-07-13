#!/bin/bash

create_inventory_file() {
    cat <<EOF > inventory.ini
[all]
localhost ansible_connection=local

[k8s-cluster]
localhost

[hyperledger_fabric]
localhost
EOF
}
