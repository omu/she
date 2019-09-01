# Parse URL

url.parse() {
	# shellcheck disable=2178,2155
	local -n variable=$(meta.public_name "$1")
	shift

	local protocol_
	local url_

	protocol_=
	case $1 in
	*://*)
		protocol_=${1%%:*}
		url_=${1#*://}
		;;
	/*|./*)
		protocol_='file'
		url_=$(readlink -m "$1")
		;;
	*)
		url_=$1
		;;
	esac

	if [[ $protocol_ == file ]]; then
		variable=(
			[protocol]=$protocol_
			[path]=$url_
		)
		return 0
	elif [[ -z $protocol_ ]]; then
		protocol_=https
	fi

	local provider_ owner_ repo_ slug_

	if ! IFS='/' read -r provider_ owner_ repo_ slug_ <<<"$url_"; then
		ui.cry "Parse error at $1"
		return 1
	fi

	[[ ${provider_:-} =~ (github.com|gitlab.com|bitbucket.com) ]] || ui.cry "Unsupported provider $provider_ at $1"
	[[ -n ${owner_:-} ]] || ui.cry "Missing owner at $1"
	[[ -n ${repo_:-} ]] || ui.cry "Missing repository at $1"

	local auth_=
	if [[ $protocol_ == https ]] && [[ -n ${HTTPS_TOKEN:-} ]]; then
		auth_="${HTTPS_TOKEN}:x-oauth-basic"
	fi

	# shellcheck disable=2034
	variable=(
		[protocol]=$protocol_
		[provider]=$provider_
		[owner]=$owner_
		[repo]=$repo_
		[slug]=$slug_
		[path]=$provider_/$owner_/$repo_
		[auth]=$auth_
	)
}
