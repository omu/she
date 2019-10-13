declare -gr _SELF=$_SELF

declare -Ag _test_=(
	[current]=0
	[start]=$SECONDS
)

t.go() {
	return 0

	local run=0 failed=0 start stop duration

	local -A seen

	local t
	for t in $(declare -F | grep 'declare -f test[:_]' | awk '{ print $3 }'); do
		if [[ -z ${seen[$t]:-} ]]; then
			unset __test_status

			echo "=== RUN $t"
			start="$SECONDS"

			"$t"

			__test_status=${__test_status:-$?}
			stop="$SECONDS"
			duration=$((stop-start))

			seen["$t"]=true

			run=$((run+1))

			if [[ "$__test_status" == 0 ]]; then
				echo "--- PASS $t (${duration}s)"
			else
				failed=$((failed+1))
				echo "--- FAIL $t (${duration}s)"
			fi
		fi
	done

	echo
	if [[ "$failed" == "0" ]]; then
		echo "Ran $run tests."
		echo
		echo "PASS"
	else
		echo "Ran $run tests. $failed failed."
		echo
		echo "FAIL"
		exit $failed
	fi
}

:load() {
	local src

	for src; do
		if [[ -f $src ]]; then
			builtin source "$src"
		fi
	done
}

:tap() {
	"$_SELF" "$@"
}

:assert() {
	local test=assert.${1?missing argument}
	shift

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

	local current=${_test_[current]}
	local message="$*"

	local err

	if "$test" err "${args[@]}"; then
		:tap success "$message" "$current"

		_test_[success]=$((${_test_[success]:-0} + 1))
	else
		:tap failure "$message" "$err" "$current"

		_test_[failure]=$((${_test_[failure]:-0} + 1))
	fi
}

# shellcheck disable=2034
t() {
	local cmd

	[[ $# -gt 0 ]] || .die 'Test command required'

	cmd=$1
	shift

	[[ $cmd =~ ^[a-z][a-z0-9-]+$ ]] || .die "Invalid command name: $cmd"

	if .callable assert."$cmd"; then
		:assert "$cmd" "$@"
	elif .callable t."$cmd"; then
		t."$cmd"
	else
		"$_SELF" "$@"
	fi
}

:load "$@"
