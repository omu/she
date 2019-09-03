# UI functions

# cry: Print warning messages on standard error
ui.cry() {
	local message

	for message; do
		echo "W: $message"
	done >&2
}

# die: Print error messages and exit failure
ui.die() {
	local message

	for message; do
		echo "E: $message"
	done >&2

	exit 1
}

# fin: Print messages and exit successfully
ui.fin() {
	local message

	for message; do
		echo "$message"
	done >&2

	exit 0
}
