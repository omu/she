# t.sh - Test functions

# Assert failed command outputs
t.err() {
	t._assert "$@"
}

# Return failure
t.fail() {
	t._assert "$@"
}

# Assert actual value equals to the expected
t.is() {
	t._assert "$@"
}

# Assert got value not equals to the expected
t.isnt() {
	t._assert "$@"
}

# Assert got value matches with the expected
t.like() {
	t._assert "$@"
}

# Assert command fails
t.notok() {
	t._assert "$@"
}

# Assert command succeeds
t.ok() {
	t._assert "$@"
}

# Assert successful command outputs
t.out() {
	t._assert "$@"
}

# Return success
t.pass() {
	t._assert "$@"
}

# Assert got value not matches with the expected
t.unlike() {
	t._assert "$@"
}

# Create and chdir to temp directory
t.temp() {
	local tempdir

	if [[ -n ${PWD[tmp]:-} ]]; then
		tempdir=${PWD[tmp]}

		temp.clean tempdir
	fi

	temp.dir tempdir

	.must -- cd "$tempdir"

	# shellcheck disable=2128
	PWD[tmp]=$PWD
}

# Run all test suites defined so far
# shellcheck disable=2034
t.go() {
	local -a _t_go_tests_

	mapfile -t _t_go_tests_ < <(
		shopt -s extdebug

		declare -F | grep 'declare -f test[.]' | awk '{ print $3 }' |
		while read -r t; do declare -F "$t"; done |
		sort -t' ' -k2 -n | awk '
			$1 !~ /test[.]setup|test[.]teardown|test[.]startup|test[.]shutdown/ {
				print $1
			}
		'
	)

	! .callable test.startup || test.startup

	local _t_go_
	for _t_go_ in "${_t_go_tests_[@]}"; do
		! .callable test.setup    || test.setup
		"$_t_go_"
		! .callable test.teardown || test.teardown
	done

	! .callable test.shutdown || test.shutdown

	tap plan total="${_test_[current]:-}"

	tap shutdown total="${_test_[current]:-}" \
		     success="${_test_[success]:-}" \
		     failure="${_test_[failure]:-0}" \
		     todo="${_test_[todo]:-0}" \
		     skip="${_test_[skip]:-0}"
}

# t - Protected functions

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

t._assert() {
	local assert=assert.${FUNCNAME[1]#*.}

	local -a args

	while [[ $# -gt 0 ]]; do
		if [[ $1 = '--' ]]; then
			shift
			break
		fi

		args+=("$1")
		shift
	done

	_test_[current]=$((${_test_[current]:-0} + 1))

	local current=${_test_[current]} message

	if [[ ${1:-} =~ [sS][kK][iI][pP]\S* ]]; then
		shift; message="$*"

		tap skip test="$message" number="$current"
		_test_[skip]=$((${_test_[skip]:-0} + 1))
		_test_[success]=$((${_test_[success]:-0} + 1))
	elif [[ ${1:-} =~ [tT][oO][dD][oO]\S* ]]; then
		shift; message="$*"

		tap todo test="$message" number="$current"
		_test_[todo]=$((${_test_[todo]:-0} + 1))
		_test_[failure]=$((${_test_[failure]:-0} + 1))
	else
		message="$*"

		local -a err

		if "$assert" err "${args[@]}"; then
			tap success test="$message" number="$current"
			_test_[success]=$((${_test_[success]:-0} + 1))
		else
			tap failure test="$message" number="$current" "${err[@]}"
			_test_[failure]=$((${_test_[failure]:-0} + 1))
		fi
	fi
}

t._reset() {
	_test_[current]=0
	_test_[start]=$SECONDS
}

# assert - Init

assert._init() {
	declare -Ag _test_=()

	t._reset
}

assert._init
