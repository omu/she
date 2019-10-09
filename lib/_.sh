# _.sh - Essential functions

[ -n "${BASH_VERSION:-}" ] || { echo >&2 'Bash required.';  exit 1; }

.prelude() {
	[[ ${BASH_VERSINFO[0]:-} -ge 4 ]] || { echo >&2 'Bash version 4 or higher required.';     exit 1; }
	[[ -x /usr/bin/apt-get         ]] || { echo >&2 'Only Debian and derivatives supported.'; exit 1; }

	set -Eeuo pipefail; shopt -s nullglob; [[ -z ${TRACE:-} ]] || set -x; unset CDPATH; IFS=$' \t\n'

	export LC_ALL=C.UTF-8 LANG=C.UTF-8

	# Program name
	# shellcheck disable=2034
	declare -ag PROGNAME=("${0##*/}")
}

.say() {
	local msg

	if [[ $# -gt 0 ]]; then
		for msg; do
			echo -e >&2 "${msg_prefix_:-}${msg}"
		done
	else
		echo >&2 ""
	fi
}

.cry() {
	local msg

	if [[ $# -gt 0 ]]; then
		for msg; do
			echo -e >&2 "${msg_prefix_:-W: }${msg}"
		done
	else
		echo >&2 ""
	fi
}

.die() {
	local msg

	if [[ $# -gt 0 ]]; then
		for msg; do
			echo -e >&2 "${msg_prefix_:-E: }${msg}"
		done
	else
		echo >&2 ""
	fi

	exit 1
}

.bug() {
	local msg

	if [[ $# -gt 0 ]]; then
		for msg; do
			echo -e >&2 "${msg_prefix_:-B: }${msg}"
		done
	else
		echo >&2 ""
	fi

	exit 127
}

.bye() {
	local msg

	if [[ $# -gt 0 ]]; then
		for msg; do
			echo -e >&2 "${msg_prefix_:-}${msg}"
		done
	else
		echo >&2 ""
	fi

	exit 0
}

.dbg() {
	[[ $# -gt 0 ]] || return 0

	# shellcheck disable=2178,2155
	local -n dbg_=$1

	echo "${!dbg_}"

	local key
	for key in "${!dbg_[@]}"; do
		printf '  %-16s  %s\n' "${key}" "${dbg_[$key]}"
	done | sort

	echo
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

.piped() {
	[[ ! -t 0 ]]
}

.interactive() {
	[[ ! -t 1 ]]
}

.bool() {
	local value=${1:-}

	value=${value,,}

	case $value in
	true|t|1|on|yes|y)
		return 0
		;;
	false|f|0|off|no|n|"")
		return 1
		;;
	*)
		.bug "Invalid boolean: $value"
	esac
}

.expired() {
	local -i expiry=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ $expiry -gt 0 ]] || return 1

	local file
	for file; do
		if [[ -e $file ]] && [[ -z $(find "$file" -mmin +"$expiry" 2>/dev/null) ]]; then
			return 1
		fi
	done

	return 0
}

_.read() {
	local -i i=1

	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
		elif [[ $1 == '--' ]]; then
			shift
			break
		else
			key=$((i++)); value=$1
		fi

		_["$key"]=${value:-${_["$key"]:-}}

		shift
	done
}

_.load() {
	# shellcheck disable=2034
	local -n _load_src_=${1?${FUNCNAME[0]}: missing argument}; shift

	array.dup _ _load_src_

	local key
	for key in "${!_load_src_[@]}"; do
		# shellcheck disable=2034
		_[$key]=${_load_src_[$key]}
	done
}

_.values() {
	local pattern=${1?${FUNCNAME[0]}: missing argument}; shift

	local -a keys

	mapfile -t keys < <(
		for key in "${!_[@]}"; do
			[[ $key =~ $pattern ]] || continue

			echo "$key"
		done | sort -u
	)

	local key

	if [[ $# -gt 0 ]]; then
		local -n _values_=$1

		for key in "${keys[@]}"; do
			_values_+=("${_[$key]}")
		done

		_values_=("${_values_[@]}")
	else
		for key in "${keys[@]}"; do
			echo "${_[$key]}"
		done
	fi
}

# Initialize underscore system

# shellcheck disable=2034
.init() {
	# Default variable as a hash
	declare -gA _=()

	# Core environment
	if [[ ${EUID:-} -eq 0 ]]; then
		readonly _RUN=${UNDERSCORE_VOLATILE_PREFIX:-/run/_}
		readonly _USR=${UNDERSCORE_PERSISTENT_PREFIX:-/usr/local}
		readonly _ETC=${UNDERSCORE_CONFIG_PATH:-/etc/_:"$_USR"/etc/_:"$_RUN"/etc}
	else
		XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/"$EUID"}
		XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
		XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}

		readonly _RUN=${UNDERSCORE_VOLATILE_PREFIX:-"$XDG_RUNTIME_DIR"/_}
		readonly _USR=${UNDERSCORE_PERSISTENT_PREFIX:-"$HOME"/.local}
		readonly _ETC=${UNDERSCORE_CONFIG_PATH:-/etc/_:/usr/local/etc/_:"$XDG_CONFIG_HOME"/_:"$_RUN"/etc}
	fi

	export PATH="$_RUN"/bin:"$PATH"

	unset -f "${FUNCNAME[0]}"
}
