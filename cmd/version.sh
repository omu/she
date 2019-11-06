# cmd/version - Print version

# Return version
:version() {
	local -A _; flag.parse

	echo "${VERSION:-}"
}

:init_() {
	declare -gr VERSION=0.0.0

	unset -f "${FUNCNAME[0]}"
}

:init_
