# Git functions

git.must_sane() {
	git rev-parse --is-inside-work-tree &>/dev/null || ui.die "Must be inside a git work tree: $PWD"
	git rev-parse --verify HEAD >/dev/null          || ui.die "Unverified git HEAD: $PWD"
}

git.is_clean() {
	git rev-parse --verify HEAD >/dev/null &&
	git update-index -q --ignore-submodules --refresh &&
	git diff-files --quiet --ignore-submodules &&
	git diff-index --cached --quiet --ignore-submodules HEAD --
}

git.must_clean() {
	git.is_clean || ui.die "Must be a clean git work tree: $PWD"
}

git.topdir() {
	local dir

	dir=$(git rev-parse --git-dir) && dir=$(cd "$dir" && pwd)/ && echo "${dir%%/.git/*}"
}

git.top() {
	git.must_sane

	must cd "$(git.topdir)"
}

# git.clone: Clone Git repository
git.clone() {
	local prefix=${GIT_ROOT:-} branch='' shallow=''

	while [[ $# -gt 0 ]]; do
		case $1 in
		-prefix|--prefix)
			[[ $# -gt 1 ]] || ui.die "Argument required for flag: $1"
			shift

			prefix=$1
			[[ -d $prefix ]] || ui.die "Prefix directory not found: $prefix"
			shift
			;;
		-branch|--branch)
			[[ $# -gt 1 ]] || ui.die "Argument required for flag: $1"
			shift

			branch=$1
			shift
			;;
		-shallow|--shallow)
			;;
		-*)
			ui.die "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac
	done

	meta.narg 1 1 "$@"

	# shellcheck disable=2034
	local -A remote local
	url.parse -prefix "${prefix:-.}" "$1" remote local

	local -a args=(git clone --quiet)

	[[ -z $branch  ]] || args+=(--branch "$branch")
	[[ -z $shallow ]] || args+=(--depth 1)

	args+=("${remote[git]}")

	local -a flags
	[[ -z $prefix ]] || flags=(-outside "${local[namespace]}" -parents)

	temp.inside "${flags[@]}" "${args[@]}"
}
