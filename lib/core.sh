# Program name
declare -grx PROGNAME=${0##*/}

# Command must success
must() {
	"$@" || abort "Command failed: $*"
}

# Command may fail
non_must() {
	"$@" || warn "Exit code $? is suppressed: $*"
}

# Print bug and fail
bug() {
	warn "BUG: ${BASH_LINENO[0]}: $*"
	exit 127
}

# Invoke command inside the given directory
inside() {
	local targetdir=$1
	shift

	local origdir=$PWD

	must cd "$targetdir"
	"$@"
	must cd "$origdir"
}
