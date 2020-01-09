# url.sh - URL processing

url.is() {
	local url=${1?${FUNCNAME[0]}: missing argument};     shift
	local feature=${1?${FUNCNAME[0]}: missing argument}; shift

	case $feature in
	local)
		[[ $url =~ ^(/.*|[.][.]?|[.][.]?/.*)$ ]]
		;;
	local+)
		[[ $url =~ ^(/.*|[.][.]?|[.][.]?/.*|file://.+)$ ]]
		;;
	naked)
		[[ ! $url =~ ^[^/]+:// ]] && [[ ! $url =~ ^(/.*|[.][.]?|[.][.]?/.*)$ ]]
		;;
	schemeless)
		[[ ! $url =~ ^[^/]+:// ]]
		;;
	schemed)
		[[ $url =~ ^[^/]+:// ]]
		;;
	*)
		.bug "Unrecognized feature: $feature"
		;;
	esac
}

url.usl() {
	usl "${_url_usl_args[@]}" "$@"
}

url.parse() {
	local exp

	exp=$(url.usl "$@") || return 1

	eval -- "$exp"
}

url.template() {
	local name=${1?${FUNCNAME[0]}: missing argument};     shift
	local template=${1?${FUNCNAME[0]}: missing argument}; shift

	_url_usl_args+=(
		'-var' "$name = $template"
	)
}

# url - Init

url.init-() {
	declare -ag _url_usl_args=()
}

url.init-
