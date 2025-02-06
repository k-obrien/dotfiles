#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Resolve URL
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🌐
# @raycast.argument1 { "type": "text", "placeholder": "URL to resolve" }

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on rg wget

[[ -n ${1:-} ]] || _error_exit "usage: $(basename "$0") https://www.example.com"

wget --post-data="url=${1}" -q -O - https://www.expandurl.net | rg -o --pcre2 '(?<=<div class="mb-3"><a class="text-link" style="overflow-wrap:break-word" target="_blank" href=")[^"]+'
