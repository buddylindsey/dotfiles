#!/bin/bash

# Command parsing code from
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?, but I don’t do that.
set -o errexit -o pipefail -o noclobber -o nounset

source /etc/os-release

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

OPTIONS=cgdv
LONGOPTS=console,gui,dev,verbose

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

c=n g=n v=n d=n
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -c|--console)
            c=y
            shift
            ;;
        -g|--gui)
            g=y
            shift
            ;;
        -v|--verbose)
            v=y
            shift
            ;;
        -d|--dev)
            d=y
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

echo "console: $c, gui: $g, dev: $d, verbose: $v"

PREFLIGHT_CHECK_SUCCESS="true"

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# Check if a command exists. Then replace.
app_installed() {
    if ! command_exists $1
    then
        PREFLIGHT_CHECK_SUCCESS="false"
        echo "$1 is not installed"
    fi
}

folder_exists() {
    [ -d "$1" ]
}

is_console() {
    [[ $c = 'y' ]]
    return
}
is_gui() {
    [[ $g = 'y' ]]
    return
}
is_verbose() {
    [[ $v = 'y' ]]
    return
}
is_dev() {
    [[ $d = 'y' ]]
    return
}

is_ubuntu () {
    [[ $NAME = 'Ubuntu' ]]
}

is_arch () {
    [[ $NAME = 'Arch Linux' ]]
}

console_copy() {
    is_console && cp $1 $2 && echo "Copied $2"
}

install_ubuntu() {
    sudo apt install $@
}

install_arch() {
    sudo pacman -Sy $@
}

# Preflight check

echo "Update package database"

#is_ubuntu && sudo apt-get update

echo "Doing System Check"

function app_check() {
    for val in "${@}"; do
        if [[ $val = "bat" ]] && [[ is_ubuntu ]]; then
            app_installed "batcat"
        elif [[ $val = "fd-find" ]] && [[ is_ubuntu ]]; then
            app_installed "fdfind"
        else
            app_installed $val
        fi
    done
}

# Check if apps are installed. Sometimes based on distro the names get changed.
# So this does a check based on distro so the correct ones get checked to be installed.
# There is also the case where it is available in a package manager on one distro, but
# not on the other.

UNIVERSAL_NAMED_CONSOLE_APPS=("git" "htop" "exa" "youtube-dl" "pianobar" "curl" "wget" "pianobar" "bat" "unzip")
UNIVERSAL_NAMED_GUI_APPS=("polybar" "rofi" "dunst")
UBUNTU_NAMED_CONSOLE_APPS=("fd-find")
ARCH_NAMED_CONSOLE_APPS=("fd" "ytop")
UBUNTU_PACKAGES=("ca-certificates" "gnupg" "lsb-release")

is_console && app_check "${UNIVERSAL_NAMED_CONSOLE_APPS[@]}"
is_console && is_ubuntu && app_check "${UBUNTU_NAMED_CONSOLE_APPS}"
is_gui && app_check  "${UNIVERSAL_NAMED_GUI_APPS[@]}"
is_gui && is_arch && app_check  "${ARCH_NAMED_GUI_APPS[@]}"


if [[ $PREFLIGHT_CHECK_SUCCESS == "false" ]]; then
    echo "Required programs not installed"
    exit 1
fi

is_console && echo "Installing Applications"

is_console && is_ubuntu && install_ubuntu "${UNIVERSAL_NAMED_CONSOLE_APPS}"
is_console && is_ubuntu && install_ubuntu "${UBUNTU_NAMED_CONSOLE_APPS}"
is_console && is_arch && install_arch "${UNIVERSAL_NAMED_CONSOLE_APPS}"
is_console && is_arch && install_arch "${ARCH_NAMED_CONSOLE_APPS}"

# Do install of console specific apps and configs

is_console && echo "Copying over root level configs"
is_console && console_copy ./files/gitconfig ~/.gitconfig

is_console && echo "Setting up command prompt"

if [ ! -d ~/.oh-my-zsh ]; then
    is_console && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
is_console && sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

# 3. Install nerd font
is_console && console_copy ./files/zshrc ~/.zshrc

OHMYZSH_PLUGINS="$HOME/.oh-my-zsh/plugins"
is_console && mkdir -p "$OHMYZSH_PLUGINS/buddy/" && console_copy ./files/oh-my-zsh/plugins/buddy/buddy.plugin.zsh "$OHMYZSH_PLUGINS/buddy/" && chmod +x "$OHMYZSH_PLUGINS/buddy/buddy.plugin.zsh"

is_console && console_copy ./files/tmux.conf ~/.tmux.conf

# If on ubuntu ytop is not available via apt

if is_dev ; then
    RUST_LOCATION="~/.cargo/bin"
    if folder_exists $RUST_LOCATION ; then
        is_dev && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    else
        is_dev && rustup update
    fi

    ASDF_LOCATION="~/.asdf"
    if folder_exists $ASDF_LOCATION ; then
        is_ubuntu && asdf update
        is_arch && cd /tmp/ && git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si
    else
        is_ubuntu && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
        is_arch && cd /tmp/ && git clone https://aur.archlinux.org/asdf-vm.git && cd asdf-vm && makepkg -si
    fi
    cd ~/
    # TODO: Figure out how to install a list of python versions and node versions
    echo "Installing Docker"
    if ! command_exists docker ; then
        if is_ubuntu ; then
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt install docker-ce docker-ce-cli containerd.io
        fi
        if is_arch ; then
            echo "Need to figure out what to do to install docker"
        fi
    fi
    is_ubuntu && apt install redis-tools postgresql-client-common
    is_arch && echo "Need to figure out how to isntall redis-cli and postgresql tools"
fi

is_gui && echo "Staring the GUI install"

install_fonts () {
    FA_VERSION="5.15.4"
    # Installing fontawesome
    pushd /tmp
    wget "https://use.fontawesome.com/releases/v${FA_VERSION}/fontawesome-free-${FA_VERSION}-desktop.zip"
    unzip "fontawesome-free-${FA_VERSION}-desktop.zip"
    cd fontawesome-free-${FA_VERSION}-desktop/otfs
    sudo mkdir /usr/local/share/fonts/fa/
    cp Font* /usr/local/share/fonts/fa
    popd
}

is_gui && install_fonts && echo "Custom fonts installed"




# To install - gui
# 1. element.io
# 2. joplin app
# 3. Alacritty
# 6. teams
# 7. Micorosft Edge
# 8. Brave Browser
# 9. Chromium
#10. Telegram
#11. QTile or leftwm
