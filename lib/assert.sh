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

# Assert actual value equals to the expected
assert.is() {
	local -n assert_is_=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_is_="Got '$got' where expected '$expected'"

	[[ $got = "$expected" ]]
}

# Assert got value not equals to the expected
assert.isnt() {
	local -n assert_isnt_=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_isnt_=("Got unexpected '$got'")

	[[ $got != "$expected" ]]
}

# Assert got value matches with the expected
assert.like() {
	local -n assert_like_=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_like_=("Got '$got' where expected to match with '$expected'")

	[[ $got =~ $expected ]]
}

# Assert got value not matches with the expected
assert.unlike() {
	local -n assert_unlike_=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_unlike_=("Got '$got' where expected to unmatch with '$expected'")

	[[ ! $got =~ $expected ]]
}

# Assert successful command outputs
assert.out() {
	local -n assert_out_=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_out_=("$(
		hope -success=true "$@"
	)")
}

# Assert failed command outputs
assert.err() {
	local -n assert_err_=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_err_=("$(
		hope -success=false "$@"
	)")
}
