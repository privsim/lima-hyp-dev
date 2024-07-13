#!/bin/bash

clone_ansible_fabric() {
    if [ ! -d "fabric-ansible-collection" ]; then
        git clone https://github.com/hyperledger-labs/fabric-ansible-collection.git
    fi
    cd fabric-ansible-collection
}
