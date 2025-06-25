#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on echo dig tr

echo $(dig +short @1.1.1.1 ch txt whoami.cloudflare +time=3 | tr -d '"')
