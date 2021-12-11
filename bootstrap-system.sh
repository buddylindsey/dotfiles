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

OPTIONS=cgv
LONGOPTS=console,gui,verbose

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

c=n g=n v=n
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

echo "console: $c, gui: $g, verbose: $v"

PREFLIGHT_CHECK_SUCCESS="true"

# Check if a command exists. Then replace.
app_installed() {
    if ! command -v $1 &> /dev/null
    then
        PREFLIGHT_CHECK_SUCCESS="false"
        echo "$1 is not installed"
    fi
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

console_copy() {
    is_console && cp $1 $2 && echo "Copied $2"
}

# Preflight check

CONSOLE_APPS=("git" "htop" "batcat" "exa" "youtube-dl" "pianobar" "curl" "wget")
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

console_copy ./files/gitconfig ~/.gitconfig

# 1. Install oh-my-zsh
# 2. Install starship
# 3. Copy over zshrc plugin
console_copy ./files/zshrc ~/.zshrc
