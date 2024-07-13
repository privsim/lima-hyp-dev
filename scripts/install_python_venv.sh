#!/bin/bash

install_python_venv() {
    if [ "$OS" = "Mac" ]; then
        brew install python
    elif [ "$OS" = "Linux" ]; then
        sudo apt-get update
        sudo apt-get install -y python3 python3-venv python3-pip
    fi
    python3 -m venv hyperledger_venv
}
