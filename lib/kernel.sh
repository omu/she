# kernel.sh - Core functions

# cry: Print warning messages on standard error
cry() {
	local message

	for message; do
		echo >&2 "$message"
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
	cry "$@"
	exit 0
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

	case $value in
	true|on|yes|1)
		return 0
		;;
	false|off|no|0|"")
		return 1
		;;
	*)
		bug "Invalid boolean: $value"
	esac
}

# Command must success
must() {
	"$@" || die "Command failed: $*"
}

# Command may fail
might() {
	"$@" || cry "Exit code $? is suppressed: $*"
}

# Announce constant (readonly) environment variable
const() {
	local export=

	while [[ $# -gt 0 ]]; do
		case $1 in
		-x|-export|--export)
			export=
			shift
			;;
		-*)
			die "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac
	done

	local -n const_reference_=$1
	shift

	local value
	for value; do
		if [[ -n $value ]]; then
			# shellcheck disable=2034
			const_reference_=$value

			declare -gr "${!const_reference_}"
			[[ -z ${export:-} ]] || export "${!const_reference_}"

			break
		fi
	done
}

# Ensure that the directory pointed by given environment variable exists
ensured() {
	local -n ensured_reference_=${1?missing 1th argument: name reference}

	[[ -n $ensured_reference_ ]] || die "Blank environment value found: $ensured_reference_"
	[[ -d $ensured_reference_ ]] || must mkdir -p "$ensured_reference_"
}

# Check timestamp of reference files against given expiry in minutes
expired() {
	local -i expiry=${1?missing 1th argument: expiry} # minutes
	shift

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

.() {
	# Program name
	const PROGNAME "${0##*/}"

	# Core environment
	if [[ ${EUID:-} -eq 0 ]]; then
		const _RUN "${UNDERSCORE_VOLATILE_PREFIX:-}"   /run/_
		const _USR "${UNDERSCORE_PERSISTENT_PREFIX:-}" /usr/local
		const _ETC  /etc/_:"$_USR"/etc/_:"$_RUN"/etc
	else
		const XDG_RUNTIME_DIR "${XDG_RUNTIME_DIR:-}" /run/"$EUID"
		const XDG_CONFIG_HOME "${XDG_CONFIG_HOME:-}" "$HOME"/.config
		const XDG_CACHE_HOME  "${XDG_CACHE_HOME:-}"  "$HOME"/.cache

		const _RUN "${UNDERSCORE_VOLATILE_PREFIX:-}"   "$XDG_RUNTIME_DIR"/_
		const _USR "${UNDERSCORE_PERSISTENT_PREFIX:-}" "$HOME"/.local
		const _ETC  /etc/_:"$XDG_CONFIG_HOME"/_:"$_RUN"/etc
	fi

	export PATH="$_RUN"/bin:"$PATH"
	export _ROOT=$_RUN

	unset -f "${FUNCNAME[0]}"
}

# init
.
