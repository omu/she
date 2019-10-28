# git.sh - Git functions

git.update() {
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

# git - Protected functions

git.is.git() {
	local path=${1:-.}

	[[ -d $path/.git ]] && git rev-parse --resolve-git-dir "$path/.git" &>/dev/null
}

git.is.clean() {
	git rev-parse --verify HEAD >/dev/null &&
	git update-index -q --ignore-submodules --refresh &&
	git diff-files --quiet --ignore-submodules &&
	git diff-index --cached --quiet --ignore-submodules HEAD --
}

# shellcheck disable=2128
git.must.sane() {
	git rev-parse --is-inside-work-tree &>/dev/null || .die "Must be inside a git work tree: $PWD"
	git rev-parse --verify HEAD >/dev/null          || .die "Unverified git HEAD: $PWD"
}

# shellcheck disable=2128
git.must.clean() {
	git.is.clean || .die "Must be a clean git work tree: $PWD"
}

git.topdir() {
	local dir

	dir=$(git rev-parse --git-dir) && dir=$(cd "$dir" && pwd)/ && echo "${dir%%/.git/*}"
}

git.top() {
	git.must.sane

	.must -- cd "$(git.topdir)"
}

git.default_branch() {
	git.must.sane

	git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

git.switch() {
	local branch=${1:-}

	[[ -n $branch ]] || branch=$(git.default_branch)

	git checkout --quiet "$branch"
}

git.dst_() {
	file.dst_ "$@"
}

git.is.exist_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	git.dst_ dst

	[[ -d $dst ]]
}

# shellcheck disable=2128
git.enter_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	git.dst_ dst

	[[ -d $dst ]] || .die "Destination not found: $dst"

	.must -- pushd "$dst" >/dev/null

	git.is.git . || .die "Not a git repository: $PWD"

	file.enter "${_[.dir]:-}"
}

git.clone_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	! git.is.exist_ "$dst" || .die "Destination already exist: $dst"

	local -a opt

	[[ -z ${_[-shallow]:-} ]] || opt+=(--depth 1)
	[[ -z ${_[.branch]:-}   ]] || opt+=(--branch "${_[.branch]}")

	_func_() {
		.getting 'Cloning repository' git clone "${opt[@]}" "$url" clone
		file.do_ copy clone "$dst"
	}

	temp.inside _func_

	unset -f _func_
}

git.update_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	git.enter_ "$dst"

	git.switch "${_[.branch]:-}"

	local -i expiry=${_[-expiry]:-3}
	if .expired "$expiry" "$(git.topdir)"/.git/FETCH_HEAD; then
		git.must.clean
		.getting 'Updating repository' git pull --quiet origin
	fi

	.must -- popd >/dev/null
}
