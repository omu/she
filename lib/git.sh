# git.sh - Git functions

git.is_git() {
	local path=$1

	[[ -d $path/.git ]] && git rev-parse --resolve-git-dir "$path/.git" &>/dev/null
}

git.must_sane() {
	git rev-parse --is-inside-work-tree &>/dev/null || die "Must be inside a git work tree: $PWD"
	git rev-parse --verify HEAD >/dev/null          || die "Unverified git HEAD: $PWD"
}

git.is_clean() {
	git rev-parse --verify HEAD >/dev/null &&
	git update-index -q --ignore-submodules --refresh &&
	git diff-files --quiet --ignore-submodules &&
	git diff-index --cached --quiet --ignore-submodules HEAD --
}

git.must_clean() {
	git.is_clean || die "Must be a clean git work tree: $PWD"
}

git.topdir() {
	local dir

	dir=$(git rev-parse --git-dir) && dir=$(cd "$dir" && pwd)/ && echo "${dir%%/.git/*}"
}

git.top() {
	git.must_sane

	must cd "$(git.topdir)"
}

git.default_branch() {
	git.must_sane

	git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

git.switch() {
	local branch=${1:-}

	[[ -n $branch ]] || branch=$(git.default_branch)

	git checkout --quiet "$branch"
}

git.refresh() {
	local -A _=(
		[-expiry]=3
	)

	flag.parse "$@"

	if expired "${_[-expiry]}" .git/FETCH_HEAD; then
		git.must_clean
		git pull --quiet origin
	fi
}

git.clone_() {
	local -a opt=(--quiet)

	[[ -z ${_[-shallow]:-} ]] || opt+=(--depth 1)
	[[ -z ${_[branch]:-}   ]] || opt+=(--branch "${_[branch]}")

	git._clone_() {
		git clone "${opt[@]}" "${_[url]}"

		_[src]=.

		file._do_ file.copy_
	}

	temp.inside git._clone_

	unset -f git._clone_

	# must cd "${_[dir]}"
}

git.refresh_() {
	must cd "${_[dst]}"

	git.switch "${_[branch]:-}"

	if expired "${_[expiry]}" .git/FETCH_HEAD; then
		git.must_clean
		git pull --quiet origin
	fi
}
