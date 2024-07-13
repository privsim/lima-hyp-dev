#!/bin/bash

start_docker_macos() {
    if [ "$OS" = "Mac" ]; then
        if ! command -v colima &> /dev/null; then
            echo "Colima not found. Installing it now."
            brew install colima
        fi
        colima start
    fi
}
