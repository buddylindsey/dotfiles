#!/bin/bash

# Command parsing code from
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?, but I don’t do that.
set -o errexit -o pipefail -o noclobber -o nounset

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

console_copy() {
    is_console && cp $1 $2 && echo "Copied $2"
}

# Preflight check

CONSOLE_APPS=("git" "htop" "batcat" "exa" "youtube-dl" "pianobar" "curl" "wget" "neofetch")
GUI_APPS=("polybar" "rofi")

function app_check() {
    for val in "${@}"; do
        is_console && app_installed $val
    done
}

is_console && app_check "${CONSOLE_APPS[@]}"
is_gui && app_check  "${GUI_APPS[@]}"


if [[ $PREFLIGHT_CHECK_SUCCESS == "false" ]]; then
    echo "Required programs not installed"
    exit 1
fi

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

is_console && console_copy ./files/tmux.conf ~/.tmux.conf
# TODO: Clone TPM execute install of plugins

# To install - console
# 1. pianobar
# 2. youtube-dl
# 3. ytop


# To install - dev
# 1. asdf-vm
# 2. rustup
# 3. python
# 4. nodejs
# 5. postgresql client apps
# 6. docker
# 7. redis-cli

# To install - gui
# 1. element.io
# 2. joplin app
# 3. Alacritty
# 4. polybar
# 5. rofi
# 6. teams
# 7. Micorosft Edge
# 8. Brave Browser
# 9. Chromium
#10. Telegram
#11. QTile
