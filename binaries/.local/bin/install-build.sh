#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/adb-common.sh"
_depend_on mktemp basename unzip find "${0%/*}/clear-app-data.sh" "${0%/*}/enable-app-deeplinks.sh" getopts

_temp_dir="$(mktemp -d)"
readonly _temp_dir

function _cleanup() {
	printf "\n%s\n" "Cleaning up..."
	# delete temp directory and files
	rm -vrf "$_temp_dir"
}

trap _cleanup EXIT

function _show_usage() {
	echo "usage: $(basename "$0") [-f] zip_file [serial_number]
          
          positional arguments:  
              zip_file  path to build archive including file name
          
          options:
              -h  show this message and exit
              -f  fresh installation; clear data and enable deeplinks"
}

function _install_build() {
	local zip_file="${1:-}"
	[[ -f "$zip_file" ]] || _error_exit "file not found: ${zip_file}"
	local fresh_installation="${2:-}"
	local device_serial_number="${3:-}"
	unzip "$zip_file" -d "$_temp_dir" 2>/dev/null || _error_exit "${zip_file} is not a valid zip file"

	declare -a apk_files
	while IFS= read -r -d $'\0'; do apk_files+=("$REPLY"); done < <(find "$_temp_dir" -type f -name "*.apk" -print0)

	for apk_file in "${apk_files[@]}"; do
		printf "\n%s\n" "Installing $(basename "$apk_file")..."
		_adb "$device_serial_number" install -r -d "$apk_file"
		local build_type=""

		if [[ "$apk_file" =~ .*release.* ]]; then
			build_type="release"
		elif [[ "$apk_file" =~ .*debug.* ]]; then
			build_type="debug"
		else
			continue
		fi

		if [[ "$fresh_installation" == true ]]; then
			local app=""
			if [[ "$apk_file" =~ .*app-plus.* ]]; then
				app="plus"
			elif [[ "$apk_file" =~ .*companion.* ]]; then
				app="comp"
			else
				continue
			fi

			if [[ -n "$app" ]]; then
				"${0%/*}"/clear-app-data.sh -a "$app" -b "$build_type" "$device_serial_number"

				if [[ "$app" == "plus" ]]; then
					printf "%s\n" "Enabling deeplinks..."
					"${0%/*}"/enable-app-deeplinks.sh -b "$build_type" "$device_serial_number"
				fi
			fi
		fi
	done
}

_fresh_installation=false

while getopts ':fh' option; do
	case "$option" in
	f)
		_fresh_installation=true
		;;

	h)
		_exit "$(_show_usage)"
		;;

	*)
		_error_exit "$(_show_usage)"
		;;
	esac
done

shift $((OPTIND - 1))

[[ -n "${1:-}" ]] || _error_exit "expected zip file"
_install_build "$1" "$_fresh_installation" "${2:-"$(_get_android_device_serial_number "a")"}"
