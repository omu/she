# Kernel

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

# fin: Print messages and exit successfully
fin() {
	cry "$@"
	exit 0
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

	local -n variable_=$1
	shift

	local value_
	for value_; do
		if [[ -n $value_ ]]; then
			# shellcheck disable=2034
			variable_=$value_

			declare -gr "${!variable_}"
			[[ -z ${export:-} ]] || export "${!variable_}"

			break
		fi
	done
}

# Ensure that the directory pointed by given environment variable exists
ensured() {
	local -n variable_=$1

	[[ -n ${!variable_} ]] || die "Blank environment value found: $variable_"
	must mkdir -p "${!variable_}"
}

# Ensure a public a variable name
public() {
	if [[ $1 =~ (^_|_$) ]]; then
		bug "Not a simple name: $1"
	else
		echo "$1"
	fi
}

# Ensure proper number of arguments given
narg() {
	local lower=$1 upper=$2
	shift 2

	[[ $# -ge $lower                                 ]] || bug "Too few arguments: $*"
	[[ -n $upper && $upper != - && $upper -le $upper ]] || bug "Too many arguments: $*"
}

# Initialize underscore system

.() {
	# Program name
	const PROGNAME "${0##*/}"

	# Core environment
	if [[ ${EUID:-} -eq 0 ]]; then
		local etc=/usr/local/etc/_
		[[ ! $PROGNAME =~ /usr/bin ]] || etc=/etc/_

		const _SRC_DIR        "${UNDERSCORE_SRC_DIR:-}"   "${SRCDIR:-}"   /run/_/src
		const _TMP_DIR        "${UNDERSCORE_TMP_DIR:-}"   "${TMPDIR:-}"   /run/_/tmp
		const _ETC_DIR        "${UNDERSCORE_ETC_DIR:-}"   "${ETCDIR:-}"   "$etc"
		const _CACHE_DIR      "${UNDERSCORE_CACHE_DIR:-}" "${CACHEDIR:-}" /run/_/cache
		const _VAR_DIR        "${UNDERSCORE_VAR_DIR:-}"   "${VARDIR:-}"   /run/_/var
	else
		const XDG_RUNTIME_DIR "${XDG_RUNTIME_DIR:-}"      /run/"$EUID"
		const XDG_CONFIG_HOME "${XDG_CONFIG_HOME:-}"      "$HOME"/.config
		const XDG_CACHE_HOME  "${XDG_CACHE_HOME:-}"       "$HOME"/.cache

		const _SRC_DIR        "${UNDERSCORE_SRC_DIR:-}"   "${SRCDIR:-}"   "$HOME"/.local/src
		const _TMP_DIR        "${UNDERSCORE_TMP_DIR:-}"   "${TMPDIR:-}"   "$XDG_RUNTIME_DIR"/_/tmp
		const _ETC_DIR        "${UNDERSCORE_ETC_DIR:-}"   "${ETCDIR:-}"   "$XDG_CONFIG_HOME"/_
		const _CACHE_DIR      "${UNDERSCORE_CACHE_DIR:-}" "${CACHEDIR:-}" "$XDG_CACHE_HOME"/_
		const _VAR_DIR        "${UNDERSCORE_VAR_DIR:-}"   "${VARDIR:-}"   "$XDG_RUNTIME_DIR"/_/var
	fi

	unset -f "${FUNCNAME[0]}"
}
. # init
