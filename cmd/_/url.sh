# cmd/url - URL processing commands

# Assert URL type
url:any() {
	local -A _=(
		[.help]='URL CLASS...'
		[.argc]=2-
	)

	flag.parse

	url.any "$@"
}

# Assert URL type
url:is() {
	local -A _=(
		[.help]='URL CLASS'
		[.argc]=2
	)

	flag.parse

	url.is "$@"
}

# Parse and dump URL
url:dump() {
	local -A _=(
		[.help]='URL ATTRIBUTE...'
		[.argc]=2-
	)

	flag.parse

	url.usl "$@"
}

init.url() {
	_url_usl_args+=(
			'-var' "cache = $_RUN/{{ .source | pathescape }}"
	)
}
