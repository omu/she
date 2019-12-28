# cmd/etc - Simple configuration management

# Get persistent variable(s)
etc:get() {
	etc:get- "${PERSISTENT[etc]}"/_ "$@"
}

# Reset persistent variable(s)
etc:reset() {
	etc:reset- "${PERSISTENT[etc]}"/_ "$@"
}

# Set persistent variable(s)
etc:set() {
	etc:set- "${PERSISTENT[etc]}"/_ "$@"
}

# Get variable(s)
var:get() {
	etc:get- "${VOLATILE[var]}"/"${_VID:-1}" "$@"
}

# Reset variable(s)
var:reset() {
	etc:reset- "${VOLATILE[var]}"/"${_VID:-1}" "$@"
}

# Set variable(s)
var:set() {
	etc:set- "${VOLATILE[var]}"/"${_VID:-1}" "$@"
}

# cmd/etc - Private functions

# Get variable(s)
etc:get-() {
	local prefix=${1?${FUNCNAME[0]}: missing argument}; shift

	local -A _=(
		[-var]=''

		[.help]='<bucket> [<variable>...]'
		[.argc]=1-
		[.raw]=true
	)

	flag.parse

	local bucket=$1
	shift

	local name=${_[-var]:-$bucket}

	# shellcheck disable=2034
	local -A result=()
	etc.get "$prefix" "$bucket" result "$@"

	.marshal result "$name"
}

etc:set-() {
	local prefix=${1?${FUNCNAME[0]}: missing argument}; shift

	local -A _=(
		[-var]=''

		[.help]='<bucket> <variable>=<value>...'
		[.argc]=2-
		[.raw]=true
	)

	flag.parse

	local bucket=$1
	shift

	local name=${_[-var]:-$bucket}

	# shellcheck disable=2034
	local -A result=()
	etc.set "$prefix" "$bucket" result "$@"

	.marshal result "$name"
}
