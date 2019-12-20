# cmd/url - URL processing commands

# Assert URL type
url:is() {
	local -A _=(
		[.help]='<url> (local|local+|naked|schemed|schemeless)'
		[.argc]=2
	)

	flag.parse

	url.is "$@"
}

# Parse and dump URL
url:dump() {
	local -A _=(
		[.help]='<url> <attribute>...'
		[.argc]=2-
	)

	flag.parse

	url.usl "$@"
}
