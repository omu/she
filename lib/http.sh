# https.sh - HTTP functions

# http.get: Get URL
http.get() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ $url =~ ^.*:// ]] || url=https://$url

	curl -fsSL "$url"
}

http.ok() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	local code
	code=$(curl -fsL -w '%{http_code}\n' -o /dev/null "$url" || true)

	[[ $code = 200 ]]
}
