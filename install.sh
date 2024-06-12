#!/bin/bash

# Function to detect the OS
detect_os() {
    os_type=$(uname -s | tr '[:upper:]' '[:lower:]')
    if [[ "$os_type" == "darwin" ]]; then
        echo "mac"
    elif [[ "$os_type" == "linux" ]]; then
        if grep -iq 'arch' /etc/os-release; then
            echo "arch"
        elif grep -iq 'ubuntu' /etc/os-release || grep -iq 'debian' /etc/os-release; then
            echo "ubuntu"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Function to get the configuration location
get_config_location_exists() {
    os_type=$1
    config_file=$2
    if [[ -f "$HOME/.config/$config_file" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to run installation scripts
run_install_scripts() {
    os_type=$1
    for script in install_scripts/*.sh; do
        if [[ -x "$script" ]]; then
            . "$script" "$os_type"
        else
            echo "Skipping non-executable script: $script"
        fi
    done
}

is_program_in_path() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_app() {
    if [[ "$os_type" == "mac" ]]; then
        install_mac
    elif [[ "$os_type" == "arch" ]]; then
        install_arch
    elif [[ "$os_type" == "ubuntu" ]]; then
        install_ubuntu
    else
        echo "Unsupported OS for 1password installation"
    fi
}

# Main
os_type=$(detect_os)
echo "Detected OS: $os_type"

if [[ "$os_type" == "unknown" ]]; then
    echo "Unsupported OS"
    exit 1
fi

run_install_scripts "$os_type"
