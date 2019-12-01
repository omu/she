# cmd/os - OS related commands

# Assert any OS feature
os:any() {
	local -A _=(
		[.help]='FEATURE...'
		[.argc]=1-
	)

	flag.parse

	os.any "$@"
}

# Print distribution codename
os:codename() {
	local -A _; flag.parse

	os.codename "$@"
}

# Print distribution name
os:dist() {
	local -A _; flag.parse

	os.dist "$@"
}

# Assert OS feature
os:is() {
	local -A _=(
		[.help]='FEATURE'
		[.argc]=1
	)

	flag.parse

	os.is "$@"
}
