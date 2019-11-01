# _.sh - Required functions

# Return if program available
_.available() {
	local -A _=(
		[.help]='PROGRAM'
		[.argc]=1
	)

	flag.parse

	.available "$@"
}

# Return if first argument found in remaining arguments
_.contains() {
	local -A _=(
		[.help]='NEEDLE HAYSTACK'
		[.argc]=2-
	)

	flag.parse

	.contains "$@"
}

# Return if any of the files expired
_.expired() {
	local -A _=(
		[-expiry]=3

		[.help]='[-expiry=MINUTES] FILE...'
		[.argc]=1-
	)

	flag.parse

	.expired "${_[-expiry]}" "$@"
}

# Ensure the given command succeeds
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

	if url.any "$url" web local; then
		file.run "$url"
	elif url.is "$url" src; then
		src.run "$url"
	else
		.die "Unsupported URL type: $url"
	fi
}

# Ignore error if the given command fails
_.should() {
	local -A _=(
		[.help]='MESSAGE ARGS...|-- ARGS...'
		[.argc]=2-
		[.dash]=true
	)

	flag.parse

	.should "$@"
}

# _ - Init

_._init() {
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

_._init
