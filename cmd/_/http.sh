# cmd/http - HTTP commands

# Assert HTTP response against any of the given codes
http:any() {
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
		http:is- "$response" "$code"
	done
}

# Get URL
http:get() {
	local -A _=(
		[.help]='URL'
		[.argc]=1
	)

	flag.parse

	http.get "$1"
}

# Assert HTTP response against the given code
http:is() {
	local -A _=(
		[.help]='URL CODE'
		[.argc]=2
	)

	flag.parse

	local url=$1 code=$2

	local response
	response=$(curl -fsL -w '%{http_code}\n' -o /dev/null "$url" || true)

	http:is- "$response" "$code"
}

# cmd/http - Protected functions

http:is-() {
	local response=${1?${FUNCNAME[0]}: missing argument}; shift
	local code=${1?${FUNCNAME[0]}: missing argument};     shift

	if [[ ${code,,} = ok ]]; then
		code=200
	fi

	[[ $response = "$code" ]]
}
