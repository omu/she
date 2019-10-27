# misc.sh - Utilities

# Check the expirations of given files
misc.expired() {
	local -A _=(
		[-expiry]=3

		[.help]='[-expiry=MINUTES] FILE...'
		[.argc]=1-
	)

	flag.parse

	.expired "${_[-expiry]}" "$@"
}

# Private functions

# Capture outputs to arrays and return exit code
# shellcheck disable=2034,2178
.capture() {
	local out err ret

	if [[ ${1?${FUNCNAME[0]}: missing argument} != '-' ]]; then
		local -n capture_out_=$1

		out=$(mktemp)
	fi
	shift

	if [[ ${1?${FUNCNAME[0]}: missing argument} != '-' ]]; then
		local -n capture_err_=$1

		err=$(mktemp)
	fi
	shift

	"$@" >"${out:-/dev/stdout}" 2>"${err:-/dev/stderr}" && ret=$? || ret=$?

	if [[ -n ${out:-} ]]; then
		mapfile -t capture_out_ <"$out" || true
		rm -f -- "$out"
	fi

	if [[ -n ${err:-} ]]; then
		mapfile -t capture_err_ <"$err" || true
		rm -f -- "$err"
	fi

	return $ret
}

