#!/bin/bash

# https://towardsdatascience.com/how-to-create-a-foolproof-interactive-terminal-menu-with-bash-scripts-97911586d4e5
### Colors ##
ESC=$(printf '\033')
RESET="${ESC}[0m"
BLACK="${ESC}[30m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
LIGHTCYAN="${ESC}[96m"
WHITE="${ESC}[37m"
DEFAULT="${ESC}[39m"

### Color Functions ##
printgreen() { printf "${GREEN}%s${RESET}\n" "$1"; }
printblue() { printf "${BLUE}%s${RESET}\n" "$1"; }
printred() { printf "${RED}%s${RESET}\n" "$1"; }
printyellow() { printf "${YELLOW}%s${RESET}\n" "$1"; }
printmagenta() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
printcyan() { printf "${CYAN}%s${RESET}\n" "$1"; }
printaqua() { printf "${LIGHTCYAN}%s${RESET}\n" "$1"; }