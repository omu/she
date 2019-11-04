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

# cmd/git - Protected functions

git:clone_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	! git.is.exist_ "$dst" || .die "Destination already exist: $dst"

	local -a opt

	[[ -z ${_[-shallow]:-} ]] || opt+=(--depth 1)
	[[ -z ${_[.branch]:-}   ]] || opt+=(--branch "${_[.branch]}")

	_func_() {
		local repo=${url##*/}; repo=${repo%.*}

		.getting 'Cloning repository' git clone "${opt[@]}" "$url" "$repo"
		file.do_ copy "$repo" "$dst"
	}

	temp.inside _func_

	unset -f _func_
}

git:dst_() {
	file:dst_ "$@"
}

git:enter_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	git.dst_ dst

	[[ -d $dst ]] || .die "Destination not found: $dst"

	.must -- pushd "$dst" >/dev/null

	# shellcheck disable=2128
	git.is.git . || .die "Not a git repository: $PWD"

	file.enter "${_[.dir]:-}"
}

git:is:exist_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	git.dst_ dst

	[[ -d $dst ]]
}

git:update_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	git:enter_ "$dst"

	git.switch "${_[.branch]:-}"

	local -i expiry=${_[-expiry]:-3}
	if .expired "$expiry" "$(git.topdir)"/.git/FETCH_HEAD; then
		git.must.clean
		.getting 'Updating repository' git pull --quiet origin
	fi

	.must -- popd >/dev/null
}
