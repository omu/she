# assert.sh - Test functions

# Assert command succeed
assert.ok() {
	case $1 in
	-msg=*)
		msg=${1#*=}
		shift
		;;
	esac

	"$@" || .die "${msg:-Command expected to succeed but failed: $@}"
}

# Assert command failed
assert.notok() {
	case $1 in
	-msg=*)
		msg=${1#*=}
		shift
		;;
	esac

	"$@" && .die "${msg:-Command expected to fail but succeeded: $@}"
}

# Assert actual value equals to expected
assert.is() {
	case $1 in
	-msg=*)
		msg=${1#*=}
		shift
		;;
	esac

	local expected=$1 actual=$2

	[[ $expected = "$actual" ]] || .die "${msg:-"Expected '$expected' where found '$actual'"}"
}
