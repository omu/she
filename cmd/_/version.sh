# cmd/version - Print version

declare -gr VERSION=0.0.0

# Return version
:version() {
	local -A _; flag.parse

	echo "${VERSION:-}"
}
