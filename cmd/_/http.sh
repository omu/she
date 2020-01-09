# cmd/http - HTTP commands

# Get URL
http:get() {
	local -A _=(
		[.help]='<url>'
		[.argc]=1
	)

	flag.parse

	local url=$1

	.ncat "$url"
}

# Assert HTTP response is ok
http:ok() {
	local -A _=(
		[.help]='<url>'
		[.argc]=1
	)

	flag.parse

	local url=$1

	.gettable "$url"
}
