#!/bin/bash

install_ansible() {
    . hyperledger_venv/bin/activate
    pip install --upgrade pip
    pip install ansible
    pip install kubernetes
    ansible --version
}
