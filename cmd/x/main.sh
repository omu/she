#=github.com/omu/home/src/sh/!.sh
#=github.com/omu/home/src/sh/_.sh

#=github.com/omu/home/src/sh/meta.sh
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
		src.get "$url" x

		x[center]=${x[cache]}

		x[target]=${x[cache]}
		[[ -z ${x[inpath]:-} ]] || x[target]=${x[cache]}/${x[inpath]}

		[[ -e ${x[target]} ]] || .die "No target found: $url"
	fi
}

main() {
	local -A _=(
	[.help]='[-cachedir=<dir>] [-tempdir=<dir>] [-ttl=<minutes>] [-fresh=<bool>] (url | file | dir) [<arg>...]'
		[.argc]=1-

		[-cachedir]="${VOLATILE[src]}"
		[-fresh]=false
		[-tempdir]="${VOLATILE[tmp]}"
		[-ttl]=30
	)

	flag.parse

	flag.false -fresh || _[-ttl]=0

	local url=$1
	shift

	# shellcheck disable=2034
	local -a env=(); flag.env env

	init _ "$url"  || .die 'Fetching failed'

	if [[ -d ${_[target]} ]]; then
		.running 'Running directory'

		#=cmd/x/dir.sh
	else
		.running 'Running file'

		#=cmd/x/file.sh
	fi

	focus  _          || .die 'Focus failed'
	setup  _          || .die 'Setup failed'
	handle _ env "$@" || .die 'Handle failed'
}

main "$@"
