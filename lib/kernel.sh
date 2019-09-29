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
	say "$@"
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

must.e() {
	local arg=${1?${FUNCNAME[0]}: missing argument};       shift
	local message=${1:-"No such file or directory: $arg"}; shift

	[[ -e $arg ]] || die message
}

must.f() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"};        shift

	[[ -f $arg ]] || die message
}

must.d() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such directory: $arg"};   shift

	[[ -d $arg ]] || die message
}

must.x() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Not executable: $arg"};      shift

	[[ -x $arg ]] || die message
}

must.r() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"};        shift

	[[ -r $arg ]] || die message
}

must.w() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"};        shift

	[[ -w $arg ]] || die message
}

must.n() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Empty value: $arg"};         shift

	[[ -n $arg ]] || die message
}

must.z() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Empty value: $arg"};         shift

	[[ -z $arg ]] || die message
}

# Command must success
must.success() {
	"$@" || die "Command failed: $*"
}

# Command may fail
may.fail() {
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
	local -n ensured_reference_=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -n $ensured_reference_ ]] || die "Blank environment value found: $ensured_reference_"
	[[ -d $ensured_reference_ ]] || must.success mkdir -p "$ensured_reference_"
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
	declare -gA _=()

	unset -f "${FUNCNAME[0]}"
}

# init
.
