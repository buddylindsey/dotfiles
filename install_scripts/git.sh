#!/bin/bash

os_type=$1

PROGRAM_NAME="git"

install_ubuntu() {
    sudo apt-get install -y git
}

if is_program_in_path $PROGRAM_NAME; then
    echo "$PROGRAM_NAME already installed"
else
    install_app
fi
