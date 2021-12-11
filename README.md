# Buddy Lindsey dotfiles

## Summary

This repo is here for my settings and installing them based on getting a new system setup. It is meant to be run after a fresh install to get everything setup. The eventual goal is I can do a fresh install of arch or ubuntu. Run this command and mysystem is setup exacly like I want it. I could expand it to MacOS, but probably wont anytime soon.

## Usage

To get started download the latest version of the bootstrap file and run it.

```
wget https://raw.githubusercontent.com/buddylindsey/dotfiles/master/bootstrap-system.sh

./bootstrap-system.sh -c
```

`-c` Will install the console apps and set configurations.

`-g` Will install gui based applications and set configurations for gui based applications. This will eventually include the window manager.
