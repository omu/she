#!/usr/bin/env bash

[ -n "${BASH_VERSION:-}"        ] || { echo >&2 'Bash required.';                     exit 1; }
[[ ${BASH_VERSINFO[0]:-} -ge 4 ]] || { echo >&2 'Bash version 4 or higher required.'; exit 1; }

# shellcheck disable=2034,2128
.prelude() {
	set -Eeuo pipefail; shopt -s nullglob; [[ -z ${TRACE:-} ]] || set -x; unset CDPATH; IFS=$' \t\n'

	export LC_ALL=C.UTF-8 LANG=C.UTF-8

	declare -ag PROGNAME=("${0##*/}") # Program name

	declare -Ag PWD; PWD[.]=$PWD      # Manage PWD
}

.prelude

.say() {
	echo -e "${@-""}"
}

.cry() {
	if [[ $# -gt 0 ]]; then
		echo -e >&2 "W: $*"
	else
		echo >&2 ""
	fi
}

.die() {
	if [[ $# -gt 0 ]]; then
		echo -e >&2 "E: $*"
	else
		echo >&2 ""
	fi

	exit 1
}

.bug() {
	if [[ $# -gt 0 ]]; then
		echo -e >&2 "BUG: $*"
	else
		echo >&2 ""
	fi

	exit 127
}

.bye() {
	if [[ $# -gt 0 ]]; then
		echo -e >&2 "$*"
	else
		echo >&2 ""
	fi

	exit 0
}

.must() {
	if [[ ${1:-} = -- ]]; then
		shift

		eval -- "${@?${FUNCNAME[0]}: missing argument}" || .die "Command failed: $*"
	else
		eval -- "${@:2}" || .die "${1?${FUNCNAME[0]}: missing argument}"
	fi
}

.might() {
	if [[ ${1:-} = -- ]]; then
		shift

		eval -- "${@?${FUNCNAME[0]}: missing argument}" || .cry "Exit code $? is suppressed: $*"
	else
		eval -- "${@:2}" || .cry "${1?${FUNCNAME[0]}: missing argument}"
	fi
}

.contains() {
	: "${1?${FUNCNAME[0]}: missing argument}"

	local element

	for element in "${@:2}"; do
		if [[ $element = "$1" ]]; then
			return 0
		fi
	done

	return 1
}

.available() {
	command -v "${1?${FUNCNAME[0]}: missing argument}" &>/dev/null
}

.callable() {
	[[ $(type -t "${1?${FUNCNAME[0]}: missing argument}" || true) == function ]]
}

.load() {
	# shellcheck disable=2128
	local _load_old_=$PWD

	[[ -v _load_dirs_ ]] || declare -ag _load_dirs_=(
		"$(dirname "$(readlink -f "$0")")"
	)

	local _load_src_

	for _load_src_; do
		builtin cd "${_load_dirs_[-1]}" || .die "Chdir error: ${_load_dirs_[-1]}"

		local _load_src_found_

		for _load_src_found_ in "$_load_src_" "$_load_src_".sh; do
			if [[ -f $_load_src_found_ ]]; then
				_load_src_found_=$(readlink -f "$_load_src_found_")

				_load_dirs_+=("$(dirname "$_load_src_found_")")

				builtin source "$_load_src_found_"
			fi
		done

		unset _load_src_found_
	done

	unset _load_src_

	builtin cd "$_load_old_" || .die "Chdir error: $_load_old_"
	unset _load_old_
}
