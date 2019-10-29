# _.sh - Required functions

_.available() {
	local -A _=(
		[.help]='PROGRAM'
		[.argc]=1
	)

	flag.parse

	.available "$@"
}

# Check the expirations of given files
_.expired() {
	local -A _=(
		[-expiry]=3

		[.help]='[-expiry=MINUTES] FILE...'
		[.argc]=1-
	)

	flag.parse

	.expired "${_[-expiry]}" "$@"
}

_.must() {
	local -A _=(
		[.help]='MESSAGE ARGS...|-- ARGS...'
		[.argc]=2-
		[.dash]=true
	)

	flag.parse

	.must "$@"
}

# Try to run any file or url
_.run() {
	local -A _=(
		[.help]='FILE|URL'
		[.argc]=1
	)

	flag.parse

	local url=$1

	if url.is "$url" web; then
		bin.run "$url"
	elif url.is "$url" src; then
		src.run "$url"
	else
		.die "Unsupported URL type: $url"
	fi
}

_.should() {
	local -A _=(
		[.help]='MESSAGE ARGS...|-- ARGS...'
		[.argc]=2-
		[.dash]=true
	)

	flag.parse

	.should "$@"
}

# _ - Protected functions

.ask() {
	.bug 'Not implemented'
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

# Capture outputs to arrays and return exit code
# shellcheck disable=2034,2178
.capture() {
	local out err ret

	if [[ ${1?${FUNCNAME[0]}: missing argument} != '-' ]]; then
		local -n capture_out_=$1

		out=$(mktemp)
	fi
	shift

	if [[ ${1?${FUNCNAME[0]}: missing argument} != '-' ]]; then
		local -n capture_err_=$1

		err=$(mktemp)
	fi
	shift

	"$@" >"${out:-/dev/stdout}" 2>"${err:-/dev/stderr}" && ret=$? || ret=$?

	if [[ -n ${out:-} ]]; then
		mapfile -t capture_out_ <"$out" || true
		rm -f -- "$out"
	fi

	if [[ -n ${err:-} ]]; then
		mapfile -t capture_err_ <"$err" || true
		rm -f -- "$err"
	fi

	return $ret
}
.calling() {
	local message="${1?${FUNCNAME[0]}: missing argument}"; shift

	.say "--> $message"

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

.err() {
	.out "$@" >&2
}

# Check the expirations of given files
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

.getting() {
	local message="${1?${FUNCNAME[0]}: missing argument}"; shift

	.say "... $message"

	"$@"
}

.interactive() {
	[[   -t 1 ]]
}

.notok() {
	.say "NOTOK $*"
}

.ok() {
	.say "OK    $*"
}

.out() {
	local arg

	for arg; do
		echo -e "$arg"
	done

	if .piped; then
		cat
	fi
}

.piped() {
	[[ ! -t 0 ]]
}

.running() {
	local message="${1?${FUNCNAME[0]}: missing argument}"; shift

	.say "... $message"

	"$@"
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
