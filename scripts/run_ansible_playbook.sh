#!/bin/bash

run_ansible_playbook() {
    . ../hyperledger_venv/bin/activate
    ansible-playbook -i inventory.ini install-oss.yml -vvv
}
