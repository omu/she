# https.sh - HTTP functions

# http.get: Get URL
http.get() {
	local url=$1

	[[ $url =~ ^.*:// ]] || url=https://$url

	curl -fsSL "$url"
}

http.ok() {
	local url=${1?missing argument: url}

	local code
	code=$(curl -fsL -w '%{http_code}\n' -o /dev/null "$url" || true)

	[[ $code = 200 ]]
}
