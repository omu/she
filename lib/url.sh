# Parse URL

url.parse() {
	local prefix_=.
	while [[ $# -gt 0 ]]; do
		case $1 in
		-prefix|--prefix)
			[[ $# -gt 1 ]] || abort "Argument required for flag: $1"
			shift

			prefix_=$1
			shift
			;;
		-*)
			abort "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac
	done

	meta.narg 2 3 "$@"

	local given_=$1
	shift

	# shellcheck disable=2178,2155
	local -n remote_=$(meta.public "$1")
	shift

	# shellcheck disable=2178,2155
	[[ $# -eq 0 ]] || local -n local_=$(meta.public "$1")

	local protocol_ url_

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
		remote_=(
			[protocol]=$protocol_
			[path]=$url_
		)
		return 0
	elif [[ -z $protocol_ ]]; then
		protocol_=https
	fi

	local provider_ owner_ repo_ slug_

	if ! IFS='/' read -r provider_ owner_ repo_ slug_ <<<"$url_"; then
		warn "Parse error at $given_"
		return 1
	fi

	[[ -n ${owner_:-} ]] || warn "Missing owner at $given_"
	[[ -n ${repo_:-}  ]] || warn "Missing repository at $given_"

	local auth_=
	if [[ $protocol_ == https ]] && [[ -n ${HTTPS_TOKEN:-} ]]; then
		auth_="${HTTPS_TOKEN}:x-oauth-basic"
	fi

	local base_
	if [[ -z $auth_ ]]; then
		base_=$protocol_://$provider_/$owner_
	else
		base_=$protocol_://$auth_@$provider_/$owner_
	fi

	local git_=$base_/$repo_.git
	[[ ${provider_:-} =~ (github.com|gitlab.com|bitbucket.com) ]] || git_=

	# shellcheck disable=2034
	remote_=(
		[auth]=$auth_
		[base]=$base_
		[canonic]=$base_/$repo_/$slug_
		[git]=$git_
		[namespace]=$provider_/$owner_
		[owner]=$owner_
		[path]=$provider_/$owner_/$repo_
		[protocol]=$protocol_
		[provider]=$provider_
		[repo]=$repo_
		[slug]=$slug_
	)

	# shellcheck disable=2034
	[[ $# -eq 0 ]] || local_=(
		[path]=$prefix_/$provider_/$owner_/$repo_
		[prefix]=$prefix_
		[namespace]=$prefix_/$provider_/$owner_
	)
}

url.is_git() {
	# shellcheck disable=2178,2155
	local -n remote_=$(meta.public "$1")

	[[ -n ${remote_[git]:-} ]]
}
#
# url.test() {
# 	# shellcheck disable=2034
# 	local -A there here
#
# 	url.parse -prefix /usr/local/src "$@" there here
#
# 	meta.print there
# 	meta.print here
#
# 	if url.is_git there; then
# 		echo OK
# 	else
# 		echo NOTOK
# 	fi
# }
#
# url.test "$@"
# exit
