# Parse URL

url.parse() {
	# shellcheck disable=2178,2155
	local -n variable=$(meta.public_name "$1")
	shift

	local given_=$1

	local protocol_
	local url_

	protocol_=
	case $given_ in
	*://*)
		protocol_=${given_%%:*}
		url_=${given_#*://}
		;;
	/*|./*)
		protocol_='file'
		url_=$(readlink -m "$given_")
		;;
	*)
		url_=$given_
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
		ui.cry "Parse error at $given_"
		return 1
	fi

	[[ ${provider_:-} =~ (github.com|gitlab.com|bitbucket.com) ]] || ui.cry "Unsupported provider $provider_ at $given_"
	[[ -n ${owner_:-} ]] || ui.cry "Missing owner at $given_"
	[[ -n ${repo_:-}  ]] || ui.cry "Missing repository at $given_"

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
