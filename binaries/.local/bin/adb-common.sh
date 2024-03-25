#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/common"

_depend_on adb awk

# get the serial number of the single attached device or prompt
# the user to make a selection if multiple devices are present
function _get_android_device_serial_number() {
  # device type to find (defaults to "a")
  # a=all, d=devices, e=emulators
  local device_type="${1:-"a"}"
  local regex
  case "$device_type" in
    d) regex="^[^emulator].*device$" ;; # e.g. 2A011JEGR08560  device
    e) regex="^emulator.*device$" ;;    # e.g. emulator-5554   device
    a) regex="device$" ;;               # all of the above; excludes e.g. 2B281FDH20059S  unauthorized
    *) _error_exit "expected d, e, or a" ;; 
  esac

  # parse the list of device serial numbers from adb
  read -r -d '' -a serial_numbers < <(adb devices | awk -v regex="$regex" 'NR>1 && $0 ~ regex { print $1 }' && printf '\0')

  declare -i num_options
  num_options=${#serial_numbers[@]}
  [[ $num_options -ge 1 ]] || _error_exit "no devices found"
  local selection

  # prompt user to select serial number if multiple options
  if [[ $num_options -gt 1 ]]; then
    while true; do
      printf >&2 "\n"
      # list serial numbers
      for ((i = 0; i < num_options; i++)); do
        printf >&2 "%d - %s\n" "$i" "${serial_numbers[i]}"
      done

      # present chooser
      printf >&2 "Select device: "
      read -r selection
      if _is_int "$selection" && [[ "$selection" -lt $num_options ]]; then
        printf >&2 "\n"
        break
      fi
    done
  else
    selection=0
  fi

  # return selected serial number
  echo "${serial_numbers[selection]}"
}

# convenience function to call adb with a device serial number
function _adb() {
  adb -s "$@"
}

function _get_device_property() {
  local key="${1:-}"
  [[ -n "$key" ]] || _error_exit "expected property key"
  _adb "${2:-"$(_get_android_device_serial_number "a")"}" shell getprop "$key"
}

function _put_device_setting() {
  [[ $# -ge 3 ]] || _error_exit "usage: _put_device_setting type key value [device_serial_number]"
  local type="${1:-}"
  local key="${2:-}"
  local value="${3:-}"
  local device_serial_number="${4:-"$(_get_android_device_serial_number "a")"}"
  _adb "$device_serial_number" shell settings put "$type" "$key" "$value"
}

function _get_android_sdk_version() {
  local device_serial_number="${1:-}"
  _get_device_property "ro.build.version.sdk" "$device_serial_number"
}

function _get_device_model() {
  local device_serial_number="${1:-}"
  _get_device_property "ro.product.model" "$device_serial_number"
}

function _is_screen_on() {
  local device_serial_number="${1:-}"
  local SCREEN_STATE_ON=2
  _string_contains "$(_get_device_property "debug.tracing.screen_state" "$device_serial_number")" "$SCREEN_STATE_ON"
}

function _is_device_locked() {
  local device_serial_number="${1:-"$(_get_android_device_serial_number "a")"}"
  declare -r SCREEN_STATE_LOCKED="mDreamingLockscreen=true"
  _string_contains "$(_adb "$device_serial_number" shell dumpsys window)" "$SCREEN_STATE_LOCKED"
}

function _toggle_talkback() {
  local state="${1:-}"
  local device_serial_number="${2:-}"
  local value_prefix

  if [[ "$state" == "on" ]]; then
    value_prefix="com.google.android.marvin.talkback"
  elif [[ "$state" == "off" ]]; then
    value_prefix="com.android.talkback"
  else
    _error_exit "usage: _toggle_talkback (on|off) [device_serial_number]"
  fi

  _put_device_setting "secure" "enabled_accessibility_services" "${value_prefix}/com.google.android.marvin.talkback.TalkBackService" "$device_serial_number"
}

function _set_font_scale() {
  local font_scale="${1:-}"
  local device_serial_number="${2:-}"
  _require_float "$font_scale"
  _put_device_setting "system" "font_scale" "$font_scale" "$device_serial_number"
}
