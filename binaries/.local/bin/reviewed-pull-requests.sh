#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reviewed Pull Requests
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon https://git-scm.com/images/logos/downloads/Git-Icon-Black.png
# @raycast.iconDark https://git-scm.com/images/logos/downloads/Git-Icon-White.png
# @raycast.argument1 { "type": "text", "placeholder": "organisation/repository" }

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on gh

gh reviewed-prs "${1:?repository required}"
