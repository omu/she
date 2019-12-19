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
		[-ttl]=-1
		[-prefix]=$_RUN

		[.help]='[-(cache=MINUTES|cache=DIR)] URL'
		[.argc]=1
	)

	flag.parse

	local url=$1
	shift

	src.enter "$url" _
}

# Return if any of the files expired
:expired() {
	local -A _=(
		[-ttl]=3

		[.help]='[-ttl=MINUTES] FILE...'
		[.argc]=1-
	)

	flag.parse

	.expired "${_[-ttl]}" "$@"
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

	# shellcheck disable=2034
	local -a env=(); flag.env_ env

	file.rune env "$@"
}

# TODO
:with() {
	# shellcheck disable=2192
	local -A _=(
		[-ttl]=-1
		[-prefix]=$_RUN

		[.help]='[-(ttl=MINUTES|cache=DIR)] URL COMMAND [ARG]...'
		[.argc]=2-
	)

	flag.parse

	# shellcheck disable=2128
	local url=$1 old_pwd=$PWD
	shift

	src.enter "$url" _
	"$@" "${_[cache]}"
	.must -- cd "$old_pwd"
}
