# is.sh - Predications at is form

# is.function: Detect function
is.function() {
	local name=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ $(type -t "$name" || true) == function ]]
}

