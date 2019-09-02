# Program name
declare -grx PROGNAME=${0##*/}

# Command must success
must() {
	"$@" || abort "Command failed: $*"
}

# Print bug and fail
bug() {
	warn "BUG: ${BASH_LINENO[0]}: $*"
	exit 127
}
