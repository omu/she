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

x() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	local target center

	if url.is "$url" local; then
		target=$url
	else
		local -A src=([url]="$ur" [root]="${const[cache]}" [expiry]="${const[expiry]}")

		src.get src

		center=${src[cache]}

		target=${src[cache]}
		[[ -z ${src[inpath]:-} ]] || target=${src[cache]}/${src[inpath]}

		[[ -e $target ]] || .die "No target found: $url"
	fi

	if [[ -d $target ]]; then
		.running "Running directory target: $target"

		#=cmd/x/file.sh
	else
		.running "Running file target: $target"

		#=cmd/x/dir.sh
	fi

	focus "$target" "$center" || .die 'Focus failed'
	setup                     || .die 'Setup failed'
	handle "$target" "$@"     || .die 'Handle failed'
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
	declare -Agr const=(
		[cache]=/tmp/t
		[expiry]=-1
	)

	main() {
		local -A _=(
			[.help]='URL|FILE [ARGS...]'
			[.argc]=1-
		)

		flag.parse

		x "$@"
	}

	main "$@"
fi
