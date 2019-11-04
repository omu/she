# url.sh - URL processing

url.any() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=
	url.type "$url" got

	local type
	for type; do
		if [[ $type = "$got" ]]; then
			return 0
		fi
	done

	return 1
}

url.is() {
	local url=${1?${FUNCNAME[0]}: missing argument};      shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	local got=
	url.type "$url" got

	[[ $expected = "$got" ]]
}

url.type() {
	local    url=${1?${FUNCNAME[0]}: missing argument};       shift
	local -n url_type_=${1?${FUNCNAME[0]}: missing argument}; shift

	url_type_=non

	if [[ $url =~ ^(/|[.]/) ]]; then
		return
	fi

	if [[ $url =~ ^([^:]+://)?(github|gitlab|bitbucket)[.]com ]]; then
		# shellcheck disable=2034
		url_type_=src
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
