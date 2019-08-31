# ui -- UI functions

# cry: Print message on standard error
ui.cry() {
	echo "$@" >&2
}

# die: Print error message and exit failure
ui.die() {
	echo "$@" >&2
	exit 1
}

# bug: Print bug message and exit failure
ui.bug() {
	echo "$@" >&2
	exit 127
}

# fin: Print a message and exit successfully
ui.fin() {
	echo "$@" >&2
	exit 0
}
