# test.sh - Test functions

# Test command succeed
test.ok() {
	_[.error]="Command expected to succeed but failed: $*"

	"$@"
}

# Test command failed
test.notok() {
	_[.error]="Command expected to fail but succeeded: $*"

	! "$@"
}

# Test actual value equals to expected
test.is() {
	local expected=$1 actual=$2

	_[.error]="Expected '$expected' where found '$actual'"

	[[ $expected = "$actual" ]]
}

test.end() {
	:
}
