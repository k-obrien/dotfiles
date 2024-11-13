#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on open

open "x-apple.systempreferences:com.apple.Profiles-Settings.extension"
open ~/.config/profiles/disable-camera.mobileconfig
