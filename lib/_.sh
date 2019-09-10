# Kernel

# Just warn on stderr
warn() {
        echo >&2 "$*"
}

# Warn and fail
abort() {
        warn "$@"
        exit 1
}

# Print bug and fail
bug() {
	warn "BUG: ${BASH_LINENO[0]}: $*"
	exit 127
}

# Warn and exit normally
fin() {
        warn "$@"
        exit 0
}

# Command must success
must() {
	"$@" || abort "Command failed: $*"
}

# Command may fail
might() {
	"$@" || warn "Exit code $? is suppressed: $*"
}

# Announce constant (readonly) environment variable
const() {
	local export=true

	while [[ $# -gt 0 ]]; do
		case $1 in
		-l|-local|--local)
			export=
			shift
			;;
		-*)
			abort "Unrecognized flag: $1"
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
			[[ -n ${export:-} ]] || export "${!variable_}"

			break
		fi
	done
}

# Ensure that the directory pointed by given environment variable exists
ensured() {
	local -n variable_=$1

	[[ -n ${!variable_} ]] || abort "Blank environment value found: $variable_"
	must mkdir -p "${!variable_}"
}

init() {
	[[ ${BASH_VERSINFO[0]:-} -ge 4 ]] || abort 'Bash version 4 or higher required.'
	[[ -x /usr/bin/apt-get         ]] || abort 'Only Debian and derivatives supported.'

	set -Eeuo pipefail; shopt -s nullglob; [[ -z ${TRACE:-} ]] || set -x; unset CDPATH

	export LC_ALL=C.UTF-8 LANG=C.UTF-8

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

init
