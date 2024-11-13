#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on profiles

profiles -R -p id.obrien.disablecamera
