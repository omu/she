# kernel.sh - Core functions

say() {
	if [[ $# -eq 0 ]]; then
		echo >&2 ""
	else
		local message

		for message; do
			echo -e >&2 "$message"
		done
	fi
}

cry() {
	if [[ $# -eq 0 ]]; then
		echo >&2 ""
	else
		local message

		for message; do
			echo -e >&2 "W: $message"
		done
	fi
}

die-() {
	if [[ $# -eq 0 ]]; then
		echo >&2 ""
	else
		local message

		for message; do
			echo -e >&2 "E: $message"
		done
	fi
}

die() {
	die- "$@"

	exit 1
}

bug-() {
	if [[ $# -eq 0 ]]; then
		echo >&2 ""
	else
		local message

		for message; do
			echo -e >&2 "B: $message"
		done
	fi
}

bug() {
	bug- "$@"

	exit 127
}

bye() {
	if [[ $# -eq 0 ]]; then
		echo >&2 ""
	else
		local message

		for message; do
			echo -e >&2 "$message"
		done
	fi

	exit 0
}

hey() {
	if [[ $# -eq 0 ]]; then
		echo >&2 ""
	else
		local message

		for message; do
			echo -e >&2 "\\e[38;5;14m-->\\e[0m\\e[1m $message\\e[0m"
		done
	fi
}

hmm() {
	while [[ $# -gt 0 ]]; do
		# shellcheck disable=2178,2155
		local -n hmm_=$1

		echo "${!hmm_}"

		local key
		for key in "${!hmm_[@]}"; do
			printf '  %-16s  %s\n' "${key}" "${hmm_[$key]}"
		done | sort
		echo

		shift
	done
}

bool() {
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
		bug "Invalid boolean: $value"
	esac
}

available() {
	command -v "$1" &>/dev/null
}

callable() {
	local name=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ $(type -t "$name" || true) == function ]]
}

piped() {
	[[ ! -t 0 ]]
}

interactive() {
	[[ ! -t 1 ]]
}

included() {
	local needle=${1?${FUNCNAME[0]}: missing argument}; shift

	local element
	for element; do
		if [[ $element = "$needle" ]]; then
			return 0
		fi
	done

	return 1
}

expired() {
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

# Initialize underscore system

# shellcheck disable=2034
.() {
	# Program name
	declare -ag PROGNAME=("${0##*/}")

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

# init
.
