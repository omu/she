# kernel.sh - Core functions

# say: Print messages on standard error
say() {
	local message

	for message; do
		echo -e >&2 "$message"
	done
}

# cry: Print warning messages on standard error
cry() {
	local message

	for message; do
		echo >&2 "W: $message"
	done
}

# die: Print error messages and exit failure
die() {
	local message

	for message; do
		echo >&2 "E: $message"
	done

        exit 1
}

# bug: Report bug and exit failure
bug() {
	local message

	for message; do
		echo >&2 "B: ${BASH_LINENO[0]}: $message"
	done

	exit 127
}

# bye: Print messages and exit successfully
bye() {
	local message

	for message; do
		echo -e >&2 "$message"
	done

	exit 0
}

# hey: Print colored messages
hey() {
	local message=$1
	shift

	echo -e >&2 "\\e[38;5;14m-->\\e[0m\\e[1m $message\\e[0m"

	for message; do
		echo -e >&2 "    $message"
	done
}

# Dump an array variable
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

# Check timestamp of reference files against given expiry in minutes
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
	readonly PROGNAME=${0##*/}

	# Core environment
	if [[ ${EUID:-} -eq 0 ]]; then
		readonly _RUN=${UNDERSCORE_VOLATILE_PREFIX:-/run/_}
		readonly _USR=${UNDERSCORE_PERSISTENT_PREFIX:-/usr/local}
		readonly _ETC=/etc/_:"$_USR"/etc/_:"$_RUN"/etc
	else
		XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/"$EUID"}
		XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
		XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}

		readonly _RUN=${UNDERSCORE_VOLATILE_PREFIX:-"$XDG_RUNTIME_DIR"/_}
		readonly _USR=${UNDERSCORE_PERSISTENT_PREFIX:-"$HOME"/.local}
		readonly _ETC=/etc/_:"$XDG_CONFIG_HOME"/_:"$_RUN"/etc
	fi

	export PATH="$_RUN"/bin:"$PATH"
	declare -gA _=()

	unset -f "${FUNCNAME[0]}"
}

# init
.
