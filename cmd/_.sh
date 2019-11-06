# cmd/_ - Essential commands

# Return if program available
:available() {
	local -A _=(
		[.help]='PROGRAM'
		[.argc]=1
	)

	flag.parse

	.available "$@"
}

# Return if first argument found in remaining arguments
:contains() {
	local -A _=(
		[.help]='NEEDLE HAYSTACK'
		[.argc]=2-
	)

	flag.parse

	.contains "$@"
}

# Enter to directory or URL
:enter() {
	local -A _=(
		[.help]='DIR|URL'
		[.argc]=1
	)

	flag.peek

	local url=$1

	local kind=
	url.kind "$url" kind

	# shellcheck disable=2153
	case $kind in
	src) .redirect src  enter "${ARGV[@]}"  ;;
	non) .redirect file enter "${ARGV[@]}"  ;;
	*)   .die "Unsupported URL kind: $kind" ;;
	esac
}

# Return if any of the files expired
:expired() {
	local -A _=(
		[-expiry]=3

		[.help]='[-expiry=MINUTES] FILE...'
		[.argc]=1-
	)

	flag.parse

	.expired "${_[-expiry]}" "$@"
}

# Ensure the given command succeeds
:must() {
	local -A _=(
		[.help]='MESSAGE ARGS...|-- ARGS...'
		[.argc]=2-
		[.dash]=true
	)

	flag.parse

	.must "$@"
}

# Try to run file or URL
:run() {
	local -A _=(
		[.help]='FILE|URL'
		[.argc]=1
	)

	flag.peek

	local url=$1

	local kind=
	url.kind "$url" kind

	# shellcheck disable=2153
	case $kind in
	web) .redirect web  run "${ARGV[@]}" ;;
	src) .redirect src  run "${ARGV[@]}" ;;
	non) .redirect file run "${ARGV[@]}" ;;
	esac
}

# Ignore error if the given command fails
:should() {
	local -A _=(
		[.help]='MESSAGE ARGS...|-- ARGS...'
		[.argc]=2-
		[.dash]=true
	)

	flag.parse

	.should "$@"
}

# cmd/_ - Init

_:init_() {
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

_:init_
