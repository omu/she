# https.sh - HTTP functions

# http.get: Get URL
http.get() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ $url =~ ^.*:// ]] || url=https://$url

	curl -fsSL "$url"
}

http.is() {
	local url=${1?${FUNCNAME[0]}: missing argument};  shift
	local code=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ ${code,,} = ok ]]; then
		code=200
	fi

	local response
	response=$(curl -fsL -w '%{http_code}\n' -o /dev/null "$url" || true)

	[[ $response = "$code" ]]
}
