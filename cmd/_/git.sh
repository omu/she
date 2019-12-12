# cmd/git - Git commands

# Git pull if repository expired
git:update() {
	local -A _=(
		[-expiry]=3

		[.help]='[-expiry=MINUTES]'
		[.argc]=0
	)

	flag.parse

	if .expired "${_[-expiry]}" .git/FETCH_HEAD; then
		git.must.clean
		.getting 'Updating repository' git pull --quiet origin
	fi
}

# TODO
git:install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_USR"/local/src

		[.help]='[-prefix=DIR] URL|FILE'
		[.argc]=1
	)

	flag.parse

	# shellcheck disable=2128
	local url=$1
	shift

	local -A src=([url]="$url" [root]="$_RUN" [expiry]=-1)

	src.get src

	[[ ${src[class]:-} = git ]] || .die "Not a git repository: $url"

	local path="${src[domain]}"/"${src[name]}"
	local dst="${_[-prefix]}"/"$path"

	[[ -d $dst ]] || .die "Already installed: $dst"

	file.cp "${src[cache]}" "$dst"
}