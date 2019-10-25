# https.sh - HTTP functions

# Get URL
http.get() {
	local -A _=(
		[.help]='URL'
		[.argc]=1
	)

	flag.parse

	local url=$1

	[[ $url =~ ^[^:]+:// ]] || url=https://$url

	curl -fsSL "$url"
}

# Assert URL response
http.is() {
	local -A _=(
		[.help]='URL CODE'
		[.argc]=2
	)

	flag.parse

	local url=$1 code=$2

	if [[ ${code,,} = ok ]]; then
		code=200
	fi

	local response
	response=$(curl -fsL -w '%{http_code}\n' -o /dev/null "$url" || true)

	[[ $response = "$code" ]]
}
