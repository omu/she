# https.sh - HTTP functions

# Assert url response against any of the given codes
http.any() {
	local -A _=(
		[.help]='URL CODE...'
		[.argc]=2-
	)

	flag.parse

	local url=$1
	shift

	local response
	response=$(curl -fsL -w '%{http_code}\n' -o /dev/null "$url" || true)

	local code

	for code; do
		http._is "$response" "$code"
	done
}

# Get url
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

# Assert url response against the given code
http.is() {
	local -A _=(
		[.help]='URL CODE'
		[.argc]=2
	)

	flag.parse

	local url=$1 code=$2

	local response
	response=$(curl -fsL -w '%{http_code}\n' -o /dev/null "$url" || true)

	http._is "$response" "$code"
}

# http - Private functions

http._is() {
	local response=${1?${FUNCNAME[0]}: missing argument}; shift
	local code=${1?${FUNCNAME[0]}: missing argument};     shift

	if [[ ${code,,} = ok ]]; then
		code=200
	fi

	[[ $response = "$code" ]]
}
