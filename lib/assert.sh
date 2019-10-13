# assert.sh - Assert functions

# Assert command succeed
# shellcheck disable=2034
assert.ok() {
	local -n assert_ok_=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_ok_="Command expected to succeed but failed: $*"

	eval -- "$@"
}

# Assert command failed
assert.notok() {
	local -n assert_notok_=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_notok_="Command expected to fail but succeeded: $*"

	! eval -- "$@"
}

# Assert actual value equals to expected
assert.is() {
	local -n assert_is_=${1?${FUNCNAME[0]}: missing argument}; shift

	local expected=${1?${FUNCNAME[0]}: missing argument}; shift
	local actual=${1?${FUNCNAME[0]}: missing argument};   shift

	assert_is_="Expected '$expected' where found '$actual'"

	[[ $expected = "$actual" ]]
}
