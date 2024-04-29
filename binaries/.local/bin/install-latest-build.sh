#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "${0%/*}/../common"

_depend_on basename find ls xargs head "${0%/*}/install-build.sh" getopts

function _show_usage() {
	echo "usage: $(basename "$0") [-f] [-b build_type] [directory]
     positional arguments:  directory   directory in which to look for build archives (default: ~/Downloads)
     options:
       -h              show this message and exit
         -f              fresh installation; clear data and enable deeplinks
           -b build_type   install latest release or debug build in given directory (default: release)"
}

function _install_latest_build() {
	local fresh_installation="${1:-}"
	local build_type="${2:-}"
	local archive_path="${3:-}"
	# find all artifacts in archive_path matching build_type, sort them with ls by modified time, and take the newest
	local zip_file
	zip_file="$(find "$archive_path" -type f -name "${build_type}-artifacts-*.zip" -print0 | xargs -0 ls -t | head -1)"
	[[ -n "$zip_file" ]] || _error_exit "no build archives found in ${archive_path}"

	declare -a arguments
	if [[ "$fresh_installation" == true ]]; then
		arguments+=("-f")
	fi

	arguments+=("$zip_file")
	"${0%/*}"/install-build.sh "${arguments[@]}"
}

_fresh_installation=false
_build_type="release"

while getopts ':fb:h' option; do
	case "$option" in
	f)
		_fresh_installation=true
		;;

	b)
		_build_type="$OPTARG"
		[[ $_build_type =~ (release|debug) ]] || _error_exit "$(_show_usage)"
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
_install_latest_build "$_fresh_installation" "$_build_type" "${1:-"${HOME}/Downloads"}"
