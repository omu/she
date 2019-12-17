#=github.com/omu/home/src/sh/!.sh

#=github.com/omu/home/src/sh/color.sh
#=github.com/omu/home/src/sh/callback.sh
#=github.com/omu/home/src/sh/defer.sh
#=github.com/omu/home/src/sh/file.sh
#=github.com/omu/home/src/sh/filetype.sh
#=github.com/omu/home/src/sh/flag.sh
#=github.com/omu/home/src/sh/git.sh
#=github.com/omu/home/src/sh/http.sh
#=github.com/omu/home/src/sh/ui.sh
#=github.com/omu/home/src/sh/temp.sh
#=github.com/omu/home/src/sh/url.sh
#=github.com/omu/home/src/sh/zip.sh
#=github.com/omu/home/src/sh/src.sh

init() {
	local -n x=${1?${FUNCNAME[0]}: missing argument}; shift
	local url=${1?${FUNCNAME[0]}: missing argument};  shift

	# shellcheck disable=2154
	if url.is "$url" local; then
		x[target]=$url
	else
		.getting "Fetching target: $url"

		local -A src=()

		SRCTMP=${x[-cache]} SRCTTL=${_[-expiry]} src.get "$url" src

		x[center]=${src[cache]}

		x[target]=${src[cache]}
		[[ -z ${src[inpath]:-} ]] || x[target]=${src[cache]}/${src[inpath]}

		[[ -e ${x[target]} ]] || .die "No target found: $url"
	fi
}

main() {
	local -A _=(
		[.help]='[OPTIONS] URL|FILE [ARGS...]'
		[.argc]=1-

		[-cache]=/tmp/t
		[-expiry]=-1
	)

	flag.parse

	local url=$1
	shift

	init _ "$url"  || .die 'Fetching failed'

	if [[ -d ${_[target]} ]]; then
		.running "Running directory target: ${_[target]}"

		#=cmd/x/file.sh
	else
		.running "Running file target: ${_[target]}"

		#=cmd/x/dir.sh
	fi

	focus  _      || .die 'Focus failed'
	setup  _      || .die 'Setup failed'
	handle _ "$@" || .die 'Handle failed'
}

main "$@"
