#!/bin/bash


PROGRAM_NAME="starship"

install_ubuntu() {
    pushd /tmp
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    popd
}


install_app
echo "$PROGRAM_NAME installed or updated"
