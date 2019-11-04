# cmd/ui - UI commands

# Print bug message and exit failure
ui:bug() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.bug "$@"
}

# Print message and exit success
ui:bye() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.bye "$@"
}

# Print message and run command
ui:calling() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1-
	)

	flag.parse

	.calling "$@"
}

# Print warning message
ui:cry() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.cry "$@"
}

# Print error message and exit failure
ui:die() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.die "$@"
}

# Print message indicating a download and run command
ui:getting() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1-
	)

	flag.parse

	.getting "$@"
}

# Print info message
ui:hmm() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.hmm "$@"
}

# Print not ok message
ui:notok() {
	local -A _=(
		[.help]='STRING'
		[.argc]=1
	)

	flag.parse

	.notok "$@"
}

# Print ok message
ui:ok() {
	local -A _=(
		[.help]='STRING'
		[.argc]=1
	)

	flag.parse

	.ok "$@"
}

# Print a busy message run command
ui:running() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1-
	)

	flag.parse

	.calling "$@"
}

# Print message on stderr
ui:say() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.say "$@"
}
