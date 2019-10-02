# must.sh - Guard functions

# Test -e
must.e() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file or directory: $arg"}

	[[ -e $arg ]] || die "$message"
}

# Test -f
must.f() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"}

	[[ -f $arg ]] || die "$message"
}

# Test -d
must.d() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such directory: $arg"}

	[[ -d $arg ]] || die "$message"
}

# Test -x
must.x() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Not executable: $arg"}

	[[ -x $arg ]] || die "$message"
}

# Test -r
must.r() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"}

	[[ -r $arg ]] || die "$message"
}

# Test -w
must.w() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No such file: $arg"}

	[[ -w $arg ]] || die "$message"
}

# Test -n
must.n() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Empty value: $arg"}

	[[ -n $arg ]] || die "$message"
}

# Test -z
must.z() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"Empty value: $arg"}

	[[ -z $arg ]] || die "$message"
}

# Must be root
must.root() {
	[[ ${EUID:-} -eq 0 ]]
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
must.available() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No program found: $arg"}

	command -v "$arg" &>/dev/null || die "$message"
}

# Function must exist
must.callable() {
	local arg=${1?${FUNCNAME[0]}: missing argument}; shift
	local message=${1:-"No function found: $arg"}

	callable "$arg" || die "$message"
}

# Stdin must exist
# shellcheck disable=2120
must.piped() {
	local message=${1:-'No stdin data found'}

	piped || die "$message"
}

# Stdout must exist
must.interactive() {
	local message=${1:-'No stdout found'}

	interactive || die "$message"
}
