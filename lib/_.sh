# _.sh - Required functions

.out() {
	local arg

	for arg; do
		echo -e "$arg"
	done

	if .piped; then
		cat
	fi
}

.err() {
	.out "$@" >&2
}

.bye() {
	.out "$@"

	exit 0
}

.net() {
	local message="${1?${FUNCNAME[0]}: missing argument}"; shift

	.say "$message..."
	"$@"
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

.piped() {
	[[ ! -t 0 ]]
}

.interactive() {
	[[   -t 1 ]]
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

# Check the expirations of given files
.expired() {
	local -i expiry=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ $expiry -gt 0 ]] || return 1

	local file
	for file; do
		if [[ -e $file ]] && [[ -z $(find "$file" -mmin +"$expiry" 2>/dev/null) ]]; then
			return 0
		fi
	done

	return 1
}

# Capture outputs to arrays and return exit code
# shellcheck disable=2034,2178
.capture() {
	local out err ret

	if [[ ${1?${FUNCNAME[0]}: missing argument} != '-' ]]; then
		local -n util_capture_out_=$1

		out=$(mktemp)
	fi
	shift

	if [[ ${1?${FUNCNAME[0]}: missing argument} != '-' ]]; then
		local -n util_capture_err_=$1

		err=$(mktemp)
	fi
	shift

	"$@" >"${out:-/dev/stdout}" 2>"${err:-/dev/stderr}" && ret=$? || ret=$?

	if [[ -n ${out:-} ]]; then
		mapfile -t util_capture_out_ <"$out" || true
		rm -f -- "$out"
	fi

	if [[ -n ${err:-} ]]; then
		mapfile -t util_capture_err_ <"$err" || true
		rm -f -- "$err"
	fi

	return $ret
}

# Initialize underscore system

.init() {
	# Default variable as a hash
	declare -gA _=()

	# shellcheck disable=2034

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
