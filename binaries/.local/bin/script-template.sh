#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on sleep basename getopts

# perform cleanup such as deleting temp files, etc
function cleanup() {
    printf "\n%s\n" "Cleaning up"
    echo "Deleting all files in root filesystem"
    sleep 1
    echo "Just kidding! 😅"
}

trap cleanup EXIT

# all code goes below here or the trap won't be set

function show_usage() {
cat << USAGE
Usage: $(basename "$0") <name>

Positional arguments:
    name  the name of a person to greet

Options:
    -h  show this message and exit
USAGE
}

function get_default_name() {
    echo "World"
}

function greet_person() {
    echo "Hello ${1:-}"
}

while getopts ':h' option; do
    case "$option" in
        h)
            _exit "$(show_usage)"
            ;;
            
        *)
            _error_exit "$(show_usage)"
            ;;
    
    esac
done

shift $((OPTIND-1))
greet_person "${1:-$(get_default_name)}"
