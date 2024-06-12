#!/bin/bash

os_type=$1

# if cargo is install assume rust is installed
PROGRAM_NAME="cargo"

install_ubuntu() {
    pushd /tmp
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    popd
}


if is_program_in_path $PROGRAM_NAME; then
    echo "rust already installed"
else
    install_app
fi
