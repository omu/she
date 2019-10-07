# test.sh - Test functions

# ok: Assert condition ok
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
