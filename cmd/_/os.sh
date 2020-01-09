# cmd/os - OS related commands

# Assert any OS feature
os:any() {
	local -A _=(
		[.help]='<feature>...'
		[.argc]=1-
		[.raw]=true
	)

	flag.parse

	os.any "$@"
}

# Assert OS feature
os:is() {
	local -A _=(
		[.help]='<feature>'
		[.argc]=1-
		[.raw]=true
	)

	flag.parse

	os.is "$@"
}

# Print OS feature
os:which() {
	local -A _=(
		[.help]='<feature>'
		[.argc]=1-
	)

	os.which "$@"
}

