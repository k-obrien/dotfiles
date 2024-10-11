#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title My Pull Requests
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon https://git-scm.com/images/logos/downloads/Git-Icon-Black.png
# @raycast.iconDark https://git-scm.com/images/logos/downloads/Git-Icon-White.png

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on gh

gh my-prs
