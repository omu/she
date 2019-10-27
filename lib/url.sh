# url.sh - URL processing

# Assert URL feature
url.is() {
	local -A _=(
		[.help]='URL (proto|host|port|path|userinfo|frag) VALUE)'
		[.argc]=3
	)

	flag.parse

	local url=$1 feature=$2 value=$3

	url.parse_ "$url"
	url.is_ "$feature" "$value"
}

# Transform URL to a getable (via supported providers) form
url.getable() {
	local -n url_getable_=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ $url_getable_ =~ ^[^:]+:// ]]; then
		return 0
	elif [[ $url_getable_ =~ ^(github.com|gitlab.com|bitbucket.com) ]]; then
		url_getable_="https://$url_getable_"

		return 0
	fi

	return 1
}

# url - Protected functions

# Parse URL
# shellcheck disable=2034
url.parse_() {
	local -n url_parse_=_

	if [[ ${1:-} = -A ]]; then
		shift
		url_parse_=${1?${FUNCNAME[0]}: missing argument}; shift
	fi

	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=1007
	local proto= userinfo= host= port= path= frag=

	if [[ $url =~ ^(/|./|file://) ]]; then
		proto='file';  url=${url#*://}
		tag=${url#*@}; url=${url%@*}
		path=$url

		# shellcheck disable=2209
		url_parse_[.proto]=file
		url_parse_[.path]=$path

		return 0
	fi

	if [[ $url =~ ^.+:// ]]; then
		proto=${url%%://*}; url=${url#*://}
	fi

	if [[ $url =~ ^[^@/]+@[^/:]+ ]]; then
		userinfo=${url%%@*}; url=${url#*@}
	fi

	if [[ $url =~ ^[^:]+:[0-9]+ ]]; then
		host=${url%%:*};      url=${url#$host:}
		port=${url%%[^0-9]*}; url=${url#$port}
	else
		host=${url%%[/:]*};   url=${url#*[/:]}
	fi

	if [[ $url =~ ^: ]]; then
		url=${url#*:}

		if [[ -n $proto ]]; then
			if [[ $proto != ssh ]]; then
				# shellcheck disable=2154
				url_parse_['!']='protocol mismatch'
				return 1
			fi
		else
			proto=ssh
		fi
	else
		url=${url#/}

		if [[ -n $proto && $proto = ssh ]]; then
			url_parse_['!']='invalid SSH url'
			return 1
		fi
	fi

	if [[ -z $proto ]]; then
		proto=https
	fi

	if [[ $url =~ [#].*$ ]]; then
		frag=${url#*#}; url=${url%#*}
	fi

	path=$url

	url_parse_[.frag]=$frag
	url_parse_[.host]=$host
	url_parse_[.path]=$path
	url_parse_[.port]=$port
	url_parse_[.proto]=$proto
	url_parse_[.userinfo]=$userinfo
}

url.is_() {
	local feature=${1?${FUNCNAME[0]}: missing argument};  shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ ${_[.${feature}]:-} = "$expected" ]]
}
