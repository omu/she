# test.sh - Test functions

# Test command succeed
test.ok() {
	case $1 in
	-msg=*)
		msg=${1#*=}
		shift
		;;
	esac

	"$@" || .die "${msg:-Command expected to succeed but failed: $@}"
}

readonly -f test.ok

# Test command failed
test.notok() {
	case $1 in
	-msg=*)
		msg=${1#*=}
		shift
		;;
	esac

	"$@" && .die "${msg:-Command expected to fail but succeeded: $@}"
}

readonly -f test.notok

# Test actual value equals to expected
test.is() {
	case $1 in
	-msg=*)
		msg=${1#*=}
		shift
		;;
	esac

	local expected=$1 actual=$2

	[[ $expected = "$actual" ]] || .die "${msg:-"Expected '$expected' where found '$actual'"}"
}

readonly -f test.is
