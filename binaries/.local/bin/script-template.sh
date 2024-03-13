#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on sleep basename getopts

# perform cleanup such as deleting temp files, etc
function _cleanup() {
    printf "\n%s\n" "Cleaning up"
    echo "Deleting all files in root filesystem"
    sleep 1
    echo "Just kidding! 😅"
}

trap _cleanup EXIT

# all code goes below here or the trap won't be set

function _show_usage() {
    echo "usage: $(basename "$0") name

positional arguments:
    name  the name of a person to greet

options:
    -h  show this message and exit
"
}

function _get_default_name() {
    echo "World"
}

function _greet_person() {
    echo "Hello ${1:-}"
}

while getopts ':h' option; do
    case "$option" in
        h)
            _exit "$(_show_usage)"
            ;;
            
        *)
            _error_exit "$(_show_usage)"
            ;;
    
    esac
done

shift $((OPTIND-1))
_greet_person "${1:-"$(_get_default_name)"}"
