# ui.sh - UI functions

# say: Print messages on standard error
ui.say() {
	local -A _=(
		[.help]='[MESSAGE...]'
		[.argc]=0-
	)

	flag.parse

	ui._plain "$@"
}

# die: Print error messages and exit failure
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

# cry: Print warning messages on standard error
ui.cry() {
	local -A _=(
		[.help]='[MESSAGE...]'
		[.argc]=0-
	)

	flag.parse

	ui._warning "$@"
}

# bug: Report bug and exit failure
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

# hey: Print messages taking attention
ui.hey() {
	local -A _=(
		[.help]='[MESSAGE...]'
		[.argc]=0-
	)

	flag.parse

	ui._hey "$@"
}

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
