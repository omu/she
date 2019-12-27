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
		[.help]='<namespace> [<variable>...]'
		[.argc]=1-
		[.raw]=true
	)

	flag.parse

	local namespace=$1
	shift

	# shellcheck disable=2034
	local -A result=()
	etc.get "$prefix" "$namespace" result "$@"

	.dbg result
}

etc:set-() {
	local prefix=${1?${FUNCNAME[0]}: missing argument}; shift

	local -A _=(
		[.help]='<namespace> <variable>=<value>...'
		[.argc]=2-
		[.raw]=true
	)

	flag.parse

	local namespace=$1
	shift

	# shellcheck disable=2034
	local -A result=()
	etc.set "$prefix" "$namespace" result "$@"

	.dbg result
}
