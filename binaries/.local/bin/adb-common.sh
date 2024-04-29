#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/../common"

_depend_on adb awk

# convenience function to call adb with a device serial number
function _adb() {
	adb -s "$@"
}

# get the serial number of the single attached device or prompt
# the user to make a selection if multiple devices are present
function _get_android_device_serial_number() {
	# device type to find (defaults to "a")
	# a=all, d=devices, e=emulators
	local device_type=${1:-a}
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

function _get_device_property() {
	local key=${1:-}
	[[ -n "$key" ]] || _error_exit "expected property key"
	_adb "${2:-$(_get_android_device_serial_number "a")}" shell getprop "$key"
}

function _put_device_setting() {
	[[ $# -ge 3 ]] || _error_exit "usage: _put_device_setting type key value [device_serial_number]"
	local type=${1:-}
	local key=${2:-}
	local value=${3:-}
	local device_serial_number=${4:-$(_get_android_device_serial_number "a")}
	_adb "$device_serial_number" shell settings put "$type" "$key" "$value"
}

function _get_android_sdk_version() {
	local device_serial_number=${1:-}
	_get_device_property ro.build.version.sdk "$device_serial_number"
}

function _get_device_model() {
	local device_serial_number=${1:-}
	_get_device_property ro.product.model "$device_serial_number"
}

function _is_screen_on() {
	local device_serial_number=${1:-}
	local SCREEN_STATE_ON=2
	_string_contains "$(_get_device_property debug.tracing.screen_state "$device_serial_number") $SCREEN_STATE_ON"
}

function _is_device_locked() {
	local device_serial_number=${1:-$(_get_android_device_serial_number "a")}
	declare -r SCREEN_STATE_LOCKED="mDreamingLockscreen=true"
	_string_contains "$(_adb "$device_serial_number" shell dumpsys window) $SCREEN_STATE_LOCKED"
}

function _unlock_device() {
	local pin=${1:-}
	local device_serial_number=${2:-}
	
	[[ -n "$pin" ]] || _error_exit "PIN or passphrase required"
	
	if ! _is_screen_on "$device_serial_number"; then
		# turn screen on
		_adb "$device_serial_number" shell input keyevent KEYCODE_POWER
		# wait for screen to wake
		_adb "$device_serial_number" shell sleep 1
	fi

	if _is_device_locked "$device_serial_number"; then
		# swipe up to reveal PIN entry screen; not strictly necessary but if
		# omitted then PIN entry box is not cleared for subsequent entries
		_adb "$device_serial_number" shell input swipe 200 800 200 0
		# input the PIN or passphrase and press enter
		_adb "$device_serial_number" shell input text "$pin"
		_adb "$device_serial_number" shell input keyevent KEYCODE_ENTER
	fi
}

function _clear_app_data() {
	local package_name=${1:-}
	local device_serial_number=${1:-$(_get_android_device_serial_number "a")}

	[[ -n "$package_name" || -n "$app_link_schemes" ]] || _error_exit "usage: _set_app_links (true|false) package_name 'app_link_scheme...' [device_serial_number]"

	_adb "$device_serial_number" shell pm clear "$package_name" || true
}

function _toggle_talkback() {
	local state=${1:-}
	local device_serial_number=${2:-$(_get_android_device_serial_number "a")}
	local value_prefix

	if [[ "$state" == "on" ]]; then
		value_prefix="com.google.android.marvin.talkback"
	elif [[ "$state" == "off" ]]; then
		value_prefix="com.android.talkback"
	else
		_error_exit "usage: _toggle_talkback (on|off) [device_serial_number]"
	fi

	_put_device_setting secure enabled_accessibility_services "$value_prefix"/com.google.android.marvin.talkback.TalkBackService "$device_serial_number"
}

function _set_font_scale() {
	local font_scale=${1:-}
	local device_serial_number=${2:-}
	_require_float "$font_scale"
	_put_device_setting "system" "font_scale" "$font_scale" "$device_serial_number"
}

function _set_app_links() {
	local enabled=${1:-}
	local package_name=${1:-}
	local app_link_schemes=${2:-}
	local device_serial_number=${4:-}

	[[ -n "$package_name" || -n "$app_link_schemes" ]] || _error_exit "usage: _set_app_links (true|false) package_name 'app_link_scheme...' [device_serial_number]"

	# Android 12+
	if [[ $(_get_android_sdk_version "$device_serial_number") -ge 31 ]]; then
		_adb "$device_serial_number" shell pm set-app-links --package "$package_name" "STATE_APPROVED/STATE_DENIED" "$app_link_schemes" 2> /dev/null || true
		_adb "$device_serial_number" shell pm set-app-links-allowed --user 0 --package "$package_name" true/false 2> /dev/null || true
		_adb "$device_serial_number" shell pm get-app-links "$package_name" 2> /dev/null || true

	# Android <= 11
	else
		_adb "$device_serial_number" shell pm set-app-link "$package_name" if $enabled; then "always"; else "never"; fi 2> /dev/null || true
		_adb "$device_serial_number" shell pm get-app-link "$package_name" 2> /dev/null || true
	fi
}
