# https.sh - HTTP functions

# http.get: Get URL
http.get() {
	local -A _=(
		[.help]='url'
		[.argc]=1
	)

	flag.parse "$@"

	local url=${_[1]}

	[[ $url =~ ^.*:// ]] || url=https://$url

	curl -fsSL "$url"
}

# http.is: Assert URL response
http.is() {
	local -A _=(
		[.help]='url code'
		[.argc]=1
	)

	flag.parse "$@"

	local url=${_[1]} code=${_[2]}

	if [[ ${code,,} = ok ]]; then
		code=200
	fi

	local response
	response=$(curl -fsL -w '%{http_code}\n' -o /dev/null "$url" || true)

	[[ $response = "$code" ]]
}
