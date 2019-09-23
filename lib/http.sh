# https.sh - HTTP functions

# http.get: Get URL
http.get() {
	local url=$1

	[[ $url =~ ^.*:// ]] || url=https://$url

	curl -fsSL "$url"
}
