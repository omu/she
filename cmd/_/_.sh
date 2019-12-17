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

# TODO
:enter() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=-1
		[-prefix]=$_RUN

		[.help]='[-(expiry=MINUTES|prefix=DIR)] URL'
		[.argc]=1
	)

	flag.parse

	local url=$1
	shift

	SRCTMP=${_[-prefix]} SRCTTL=${_[-expiry]} src.enter "$url"
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

	.must -- "$@"
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

# TODO
:run() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='FILE|DIR [ARG]...'
		[.argc]=2-
	)

	flag.parse
	:
}

# TODO
:with() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=-1
		[-prefix]=$_RUN

		[.help]='[-(expiry=MINUTES|prefix=DIR)] URL COMMAND [ARG]...'
		[.argc]=2-
	)

	flag.parse

	# shellcheck disable=2128
	local url=$1 old_pwd=$PWD
	shift

	local -A src=()

	SRCTMP=${_[-prefix]} SRCTTL=${_[-expiry]} src.enter "$url" src
	"$@" "${src[cache]}"
	.must -- cd "$old_pwd"
}

# cmd/_ - Init

init.early_() {
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

	export PATH="$_RUN"/bin:"$PATH" SRCTMP="$_RUN"
}
