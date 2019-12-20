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

# Run local file with optional environment
:run() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='FILE|DIR [ARG]...'
		[.argc]=2-
	)

	flag.parse

	# shellcheck disable=2034
	local -a env=(); flag.env env

	file.rune env "$@"
}
