#!/bin/bash


PROGRAM_NAME="procs"

install_ubuntu() {
    pushd /tmp
    pwd

    REPO='dalance/procs'
    ARCHIVE_FILE='procs.zip'
    APP_VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    EXTRACT_LOCATION='procs'
    GITHUB_ARCHIVE="procs-v${APP_VERSION}-x86_64-linux.zip"

    curl -sLo $ARCHIVE_FILE -s https://github.com/$REPO/releases/download/v$APP_VERSION/$GITHUB_ARCHIVE
    unzip $ARCHIVE_FILE
    sudo install $EXTRACT_LOCATION /usr/local/bin

    popd
}

if is_program_in_path $PROGRAM_NAME; then
    echo "$PROGRAM_NAME already installed"
else
    install_app
fi
