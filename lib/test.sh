# test.sh - Test functions

# Assert condition ok
test.ok() {
	local -A _=(
		[-msg]='Condition failed'

		[.help]='[-msg=MESSAGE] CONDITION'
		[.argc]=1
	)

	flag.parse

	local cond=$1

	"$cond" || die "${_[-msg]}"
}

# Assert condition not ok
test.notok() {
	test.ok -msg='Condition succeded' "$@"
}
