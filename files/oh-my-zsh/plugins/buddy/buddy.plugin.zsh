#!/bin/bash

#alias activate="source ./.venv/bin/activate"
alias msp="python manage.py shell_plus"
alias ms="python manage.py shell"
alias runs="python manage.py runserver"
alias runsp="python manage.py runserver_plus"

OS=`cat /etc/os-release | grep ^ID= | cut -d '=' -f2`

application_rename() {
    # Used to set alias when renaming from one program
    # to another.
    if ! command -v $2 &> /dev/null
    then
        echo "$2 is not installed try 'apt install $2'"
    else
        alias $1=$2
    fi
}

if [[ $OS = 'ubuntu' ]]; then
    application_rename "cat" "batcat"
else
    application_rename "cat" "bat"
fi

application_rename "ls" "exa"
alias gcat="/usr/bin/cat"
alias vim="nvim"

activate() {
    POETRY_FILE="`pwd`/pyproject.toml"
    if [[ -f "$POETRY_FILE" ]]; then
        if grep -Fq "tool.poetry" "$POETRY_FILE"; then
            poetry shell
        fi
    fi

    VENV="`pwd`/.venv"
    [[ -d "$VENV" ]] && source ./.venv/bin/activate
}
