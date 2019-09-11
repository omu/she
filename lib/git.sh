# Git functions

declare -Ag _git=(
	[lazy_expiry]=3600
	[eager_expiry]=180
	[shibboleth]=_
)

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

# shellcheck disable=2120
git.refresh() {
	local branch=master expiry=180

	while [[ $# -gt 0 ]]; do
		case $1 in
		-expiry|--expiry)
			[[ $# -gt 1 ]] || die "Argument required for flag: $1"
			shift

			expiry=$1
			shift
			;;
		-branch|--branch)
			[[ $# -gt 1 ]] || die "Argument required for flag: $1"
			shift

			branch=$1
			shift
			;;
		-*)
			die "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac
	done

	narg 0 0 "$@"

	if expired "$expiry" .git/"${_git[shibboleth]}" .git/FETCH_HEAD; then
		git.must_clean
		git checkout --quiet "$branch"
		git pull --quiet origin "$branch"

		must touch .git/"${_git[shibboleth]}"
	fi
}

# shellcheck disable=2120
git.always_refresh() {
	git.refresh -branch "${1:-master}" -expiry 0
}

# shellcheck disable=2120
git.lazy_refresh() {
	git.refresh -branch "${1:-master}" -expiry "${_git[lazy_expiry]}"
}

# shellcheck disable=2120
git.eager_refresh() {
	git.refresh -branch "${1:-master}" -expiry "${_git[eager_expiry]}"
}

# git.get: Get (clone or update) Git repository
git.get() {
	local prefix=${_SRC_DIR:-} branch='' shallow='' cached=''

	while [[ $# -gt 0 ]]; do
		case $1 in
		-prefix|--prefix)
			[[ $# -gt 1 ]] || die "Argument required for flag: $1"
			shift

			prefix=$1
			[[ -d $prefix ]] || die "Prefix directory not found: $prefix"
			shift
			;;
		-branch|--branch)
			[[ $# -gt 1 ]] || die "Argument required for flag: $1"
			shift

			branch=$1
			shift
			;;
		-shallow|--shallow)
			shallow=true
			shift
			;;
		-cached|--cached)
			cached=true
			shift
			;;
		-*)
			die "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac
	done

	narg 1 1 "$@"

	# shellcheck disable=2034
	local -A remote local
	url.parse -prefix "${prefix:-.}" "$1" remote local

	local repo=${local[path]}

	if [[ ! -d $repo ]]; then
		local -a args=(git clone --quiet)

		[[ -z $branch  ]] || args+=(--branch "$branch")
		[[ -z $shallow ]] || args+=(--depth 1)

		args+=("${remote[git]}")

		local -a flags
		[[ -z $prefix ]] || flags=(-outside "${local[namespace]}" -parents)

		temp.inside "${flags[@]}" "${args[@]}"

		must cd "$repo"
		must touch .git/"${_git[shibboleth]}"
	else
		must cd "$repo"

		if [[ -n ${cached:-} ]]; then
			# shellcheck disable=2119
			git.lazy_refresh
		else
			# shellcheck disable=2119
			git.eager_refresh
		fi
	fi
}
