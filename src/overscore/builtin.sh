declare -grx OVERSCORE=$OVERSCORE

.t() {
	local run=0 failed=0 start stop duration

	local -A seen

	local t
	for t in $(declare -F | grep 'declare -f test[._]' | awk '{ print $3 }'); do
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

t() {
	if [[ $# -gt 0 ]]; then
		local name=$1
		shift

		local assert=assert."$name"

		[[ $(type -t "$assert" || true) == function ]]

		"$assert" "$@"

		return 0
	fi

	(
		. ../../bin/underscore

		.t
	) || exit 1
}
