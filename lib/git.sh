# git.sh - Git functions

git.default_branch() {
	git.must.sane

	git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

git.is.clean() {
	git rev-parse --verify HEAD >/dev/null &&
	git update-index -q --ignore-submodules --refresh &&
	git diff-files --quiet --ignore-submodules &&
	git diff-index --cached --quiet --ignore-submodules HEAD --
}

git.is.git() {
	local path=${1:-.}

	[[ -d $path/.git ]] && git rev-parse --resolve-git-dir "$path/.git" &>/dev/null
}

git.must.clean() {
	# shellcheck disable=2128
	git.is.clean || .die "Must be a clean git work tree: $PWD"
}

git.must.sane() {
	# shellcheck disable=2128
	git rev-parse --is-inside-work-tree &>/dev/null || .die "Must be inside a git work tree: $PWD"
	# shellcheck disable=2128
	git rev-parse --verify HEAD >/dev/null          || .die "Unverified git HEAD: $PWD"
}

git.switch() {
	local branch=${1:-}

	[[ -n $branch ]] || branch=$(git.default_branch)

	git checkout --quiet "$branch"
}

git.top() {
	git.must.sane

	.must -- cd "$(git.topdir)"
}

git.topdir() {
	local dir

	dir=$(git rev-parse --git-dir) && dir=$(cd "$dir" && pwd)/ && echo "${dir%%/.git/*}"
}
