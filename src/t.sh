declare -gr _SELF=$_SELF

declare -Ag _test_=(
	[current]=0
	[start]=$SECONDS
)

.self() {
	"$_SELF" "$@"
}

.assert() {
	local assert=assert.${1?${FUNCNAME[0]}: missing argument}; shift

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

	local -a err

	if [[ ${1:-} =~ [sS][kK][iI][pP]\S* ]]; then
		shift

		message="$*"

		.self tap skip test="$message" number="$current"
		_test_[skip]=$((${_test_[skip]:-0} + 1))
		_test_[success]=$((${_test_[success]:-0} + 1))

		return
	elif [[ ${1:-} =~ [tT][oO][dD][oO]\S* ]]; then
		shift

		message="$*"

		.self tap todo test="$message" number="$current"
		_test_[todo]=$((${_test_[todo]:-0} + 1))
		_test_[failure]=$((${_test_[failure]:-0} + 1))

		return
	fi

	message="$*"

	if "$assert" err "${args[@]}"; then
		.self tap success test="$message" number="$current"
		_test_[success]=$((${_test_[success]:-0} + 1))
	else
		.self tap failure test="$message" number="$current" "${err[@]}"
		_test_[failure]=$((${_test_[failure]:-0} + 1))
	fi
}

t.skip() {
	local message=${1?${FUNCNAME[0]}: missing argument}; shift

	_test_[current]=$((${_test_[current]:-0} + 1))

	local current=${_test_[current]}

	.self tap success test="$message" number="$current"
	_test_[success]=$((${_test_[success]:-0} + 1))
}

t.temp() {
	local tempdir

	if [[ -n ${PWD[tmp]:-} ]]; then
		tempdir=${PWD[tmp]}

		temp.clean tempdir
	fi

	temp.dir tempdir

	cd "$tempdir" || .die "Chdir error: $tempdir"

	# shellcheck disable=2128
	PWD[tmp]=$PWD
}

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

	.self tap plan	total="${_test_[current]:-}" \
			success="${_test_[success]:-}" \
			failure="${_test_[failure]:-0}" \
			todo="${_test_[todo]:-0}" \
			skip="${_test_[skip]:-0}"
}

# shellcheck disable=2034
t() {
	local cmd

	[[ $# -gt 0 ]] || .die 'Test command required'

	cmd=$1
	shift

	[[ $cmd =~ ^[a-z][a-z0-9-]+$ ]] || .die "Invalid command name: $cmd"

	if .callable assert."$cmd"; then
		.assert "$cmd" "$@"
	elif .callable t."$cmd"; then
		t."$cmd"
	else
		.self "$@"
	fi
}

[[ $# -eq 0 ]] || .load "$@"
