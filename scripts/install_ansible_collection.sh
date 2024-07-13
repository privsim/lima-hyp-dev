#!/bin/bash

install_ansible_collection() {
    . ../hyperledger_venv/bin/activate
    ansible-galaxy collection build
    ansible-galaxy collection install hyperledger-fabric_ansible_collection-*.tar.gz
}
