# ui.sh - UI functions

# Print messages on standard error
ui.say() {
	local -A _=(
		[.help]='[MESSAGE...]'
		[.argc]=0-
	)

	flag.parse

	ui._plain "$@"
}

# Print error messages and exit failure
ui.die() {
	local -A _=(
		[-unexit]=false
		[.help]='[-unexit=BOOL [MESSAGE...]]'
		[.argc]=0-
	)

	flag.parse

	ui._error "$@"

	flag.true unexit || exit 1
}

# Print warning messages on standard error
ui.cry() {
	local -A _=(
		[.help]='[MESSAGE...]'
		[.argc]=0-
	)

	flag.parse

	ui._warning "$@"
}

# Report bug and exit failure
ui.bug() {
	local -A _=(
		[-unexit]=false
		[.help]='[-unexit=BOOL [MESSAGE...]]'
		[.argc]=0-
	)

	flag.parse

	ui._bug "$@"

	flag.true unexit || exit 127
}

# Print messages taking attention
ui.hey() {
	local -A _=(
		[.help]='[MESSAGE...]'
		[.argc]=0-
	)

	flag.parse

	ui._hey "$@"
}

# ui - Private functions

ui._plain() {
	local message

	for message; do
		echo -e >&2 "$message"
	done
}

ui._error() {
	local message

	for message; do
		echo -e >&2 "E: $message"
	done
}

ui._warning() {
	local message

	for message; do
		echo -e >&2 "W: $message"
	done
}

ui._bug() {
	local message

	for message; do
		echo -e >&2 "B: $message"
	done
}

ui._hey() {
	local message

	for message; do
		echo -e >&2 "\\e[38;5;14m-->\\e[0m\\e[1m $message\\e[0m"
	done
}
