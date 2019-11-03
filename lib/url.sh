# url.sh - URL processing

url.type() {
	local    url=${1?${FUNCNAME[0]}: missing argument};       shift
	local -n url_type_=${1?${FUNCNAME[0]}: missing argument}; shift

	url_type_=none

	if [[ $url =~ ^(/|[.]/) ]]; then
		url_type_=local
		return
	fi

	if [[ $url =~ ^([^:]+://)?(github|gitlab|bitbucket)[.]com ]]; then
		# shellcheck disable=2034
		url_type_=src
		return
	fi

	if [[ ! $url =~ ^([^:]+://) ]]; then
		# shellcheck disable=2034
		url_type_=local
		return
	fi

	if [[ $url =~ ^(http|https):// ]]; then
		# shellcheck disable=2034
		url_type_=web
		return
	fi

	if [[ $url =~ ^(git|git[+]ssh|ssh):// ]]; then
		# shellcheck disable=2034
		url_type_=src
		return
	fi
}
