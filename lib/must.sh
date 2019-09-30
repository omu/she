# must.sh - Guard functions

must.e() {
	local arg=${1?${FUNCNAME[0]}: missing argument};       shift
	local message=${1:-"No such file or directory: $arg"}

	[[ -e $arg ]] || die "$message"
}

must.f() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"}

	[[ -f $arg ]] || die "$message"
}

must.d() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such directory: $arg"}

	[[ -d $arg ]] || die "$message"
}

must.x() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Not executable: $arg"}

	[[ -x $arg ]] || die "$message"
}

must.r() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"}

	[[ -r $arg ]] || die "$message"
}

must.w() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"}

	[[ -w $arg ]] || die "$message"
}

must.n() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Empty value: $arg"}

	[[ -n $arg ]] || die "$message"
}

must.z() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Empty value: $arg"}

	[[ -z $arg ]] || die "$message"
}

# Command must success
must.success() {
	"$@" || die "Command failed: $*"
}

# Command may fail but must proceed
must.proceed() {
	"$@" || cry "Exit code $? is suppressed: $*"
}

# Condition must be true
must.true() {
	local message=${1?${FUNCNAME[0]}: missing argument}; shift

	"$@" || die "$message"
}

# Condition must be false
must.false() {
	local message=${1?${FUNCNAME[0]}: missing argument}; shift

	"$@" && die "$message"
}

# Program must exist
must.program() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No program found: $arg"}

	command -v "$arg" &>/dev/null || die "$message"
}

