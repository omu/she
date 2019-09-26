# git.sh - Git functions

git.is_git() {
	local path=${1:-.}

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

git.update() {
	local -A _=(
		[-expiry]=3
	)

	flag.parse "$@"

	if expired "${_[-expiry]}" .git/FETCH_HEAD; then
		git.must_clean
		git pull --quiet origin
	fi
}

git.dst_() {
	file.dst_ "$@"
}

git.exist_() {
	local dst=${1?missing 1st argumenet: dst}

	git.dst_ dst

	[[ -d $dst ]]
}

git.enter_() {
	local dst=${1?missing 1st argument: dst}

	git.dst_ dst

	[[ -d $dst ]] || die "Destination not found: $dst"

	must pushd "$dst" >/dev/null

	git.is_git . || die "Not a git repository: $PWD"

	file.enter "${_[.dir]:-}"
}

git.clone_() {
	local url=${1?missing 1th argument: url}
	local dst=${2?missing 2nd argument: dst}

	! git.exist_ "$dst" || die "Destination already exist: $dst"

	local -a opt

	[[ -z ${_[-shallow]:-} ]] || opt+=(--depth 1)
	[[ -z ${_[.branch]:-}   ]] || opt+=(--branch "${_[.branch]}")

	_func_() {
		git clone "${opt[@]}" "$url" .
		file.do_ copy . "$dst"
	}

	temp.inside _func_

	unset -f _func_
}

git.update_() {
	local dst=${1?missing 1st argument: dst}

	git.enter_ "$dst"

	git.switch "${_[.branch]:-}"

	local -i expiry=${_[-expiry]:-3}
	if expired "$expiry" .git/FETCH_HEAD; then
		git.must_clean

		cry 'Updating repository...'
		git pull --quiet origin
	fi

	must popd >/dev/null
}
