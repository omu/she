# cmd/t - Testing

# Assert failed command outputs
t:err() {
	t:assert_ "$@"
}

# Return failure
t:fail() {
	t:assert_ "$@"
}

# Assert actual value equals to the expected
t:is() {
	t:assert_ "$@"
}

# Assert got value not equals to the expected
t:isnt() {
	t:assert_ "$@"
}

# Assert got value matches with the expected
t:like() {
	t:assert_ "$@"
}

# Assert command fails
t:notok() {
	t:assert_ "$@"
}

# Assert command succeeds
t:ok() {
	t:assert_ "$@"
}

# Assert successful command outputs
t:out() {
	t:assert_ "$@"
}

# Return success
t:pass() {
	t:assert_ "$@"
}

# Assert got value not matches with the expected
t:unlike() {
	t:assert_ "$@"
}

# Create and chdir to temp directory
t:temp() {
	local tempdir

	[[ -v T ]] || declare -Ag T=()

	if [[ -n ${T[tmp]:-} ]]; then
		tempdir=${T[tmp]}

		temp.clean tempdir
	fi

	temp.dir tempdir

	.must -- cd "$tempdir"

	# shellcheck disable=2128
	T[tmp]=$PWD
}

# Run all test suites defined so far
# shellcheck disable=2034
t:go() {
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

# cmd/t - Protected functions

t:assert_() {
	local assert=assert.${FUNCNAME[1]#*:}

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

t:reset_() {
	_test_[current]=0
	_test_[start]=$SECONDS
}

# assert - Init

t:init_() {
	declare -Ag _test_=()

	t:reset_
}

t:init_
