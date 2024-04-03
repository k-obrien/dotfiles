#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Show Open Pull Requests
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon https://git-scm.com/images/logos/downloads/Git-Icon-Black.png
# @raycast.iconDark https://git-scm.com/images/logos/downloads/Git-Icon-White.png
# @raycast.argument1 { "type": "text", "placeholder": "organisation/repository" }

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on gh

gh search prs \
    --repo "${1:?repository required}" \
    --state=open \
    --limit=10 \
    --draft=false \
    --checks=success \
    --json createdAt,commentsCount,title,url \
    --jq '.[].createdAt |= sub("T.+Z"; "") | sort_by(.createdAt, .commentsCount) | .[0:9][] | "\(.title)\n\(.url)\n"'
