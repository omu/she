# assert.sh - Assertions

assert.err() {
	local -n assert_err_=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2034
	assert_err_=("$(
		hope -success=false "$@"
	)")
}

assert.fail() {
	false
}

assert.is() {
	local -n assert_is_=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2034
	assert_is_="Got '$got' where expected '$expected'"

	[[ $got = "$expected" ]]
}

assert.isnt() {
	local -n assert_isnt_=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2034
	assert_isnt_=("Got unexpected '$got'")

	[[ $got != "$expected" ]]
}

assert.like() {
	local -n assert_like_=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2034
	assert_like_=("Got '$got' where expected to match with '$expected'")

	[[ $got =~ $expected ]]
}

assert.notok() {
	local -n assert_notok_=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2034
	assert_notok_="Command expected to fail but succeeded: $*"

	! eval -- "$@"
}

# shellcheck disable=2034
assert.ok() {
	local -n assert_ok_=${1?${FUNCNAME[0]}: missing argument}; shift

	assert_ok_="Command expected to succeed but failed: $*"

	eval -- "$@"
}

assert.out() {
	local -n assert_out_=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2034
	assert_out_=("$(
		hope -success=true "$@"
	)")
}

assert.pass() {
	true
}

assert.unlike() {
	local -n assert_unlike_=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2034
	assert_unlike_=("Got '$got' where expected to unmatch with '$expected'")

	[[ ! $got =~ $expected ]]
}

