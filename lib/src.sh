# src.sh - Source management

# src.install: Install (clone or update) Git repository to a known location
src.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_ROOT"/src
		[-shallow]=
	)

	flag.parse "$@"

	src.install_
}

# enter: Get files from URL and chdir to directory
src.enter() {
	src.install "$@"

	[[ -n ${_[-dir]:-} ]] || return 0

	[[ -e ${_[-dir]} ]] || die "No path found: ${_[-name]}: ${_[-dir]}"

	if [[ -d ${_[-dir]} ]]; then
		must cd "${_[-dir]}"
	elif [[ -f ${_[-dir]} ]]; then
		must cd "${_[-dir]%/*}"
	else
		die "No path found: ${_[-name]}: ${_[-dir]}"
	fi
}

src.is_managed_path() {
	local path=${1?missing argument: path}

	git.is_git "$path" && git -C "$path" config underscore.name &>/dev/null
}

src.install_() {
	local url=${_[1]?missing argument: url}

	url.parse "$url" || die "Error parsing URL: ${_[error]}: $url"

	src._plan_ || die "Error planning for Git URL: ${_[error]}: $url"

	if [[ ! -d ${_[dst]} ]]; then
		git.clone_
	else
		git.refresh_
	fi
}

src._plan_() {
	local owner repo auth path

	if [[ ! ${_[host]} =~ ^(github.com|gitlab.com|bitbucket.com)$ ]]; then
		# shellcheck disable=2154
		_[error]='unsupported provider'
		return 1
	fi

	path=${_[path]:-}

	if [[ ! $path =~ [^/]+/[^/]+ ]]; then
		_[error]='incomplete url'
		return 1
	fi

	owner=${path%%/*}; path=${path#*/}

	_[-dir]=
	if [[ $path = */* ]]; then
		_[-dir]=${path#*/}; path=${path%%/*}
	fi

	repo=${path%.git}

	_[-name]=${_[host]}/$owner/$repo
	_[-branch]=${_[tag]:-}

	if [[ ${_[proto]} == https ]] && [[ -n ${HTTPS_TOKEN:-} ]]; then
		auth="${HTTPS_TOKEN}:x-oauth-basic"
	else
		auth=${_[userinfo]}
	fi

	if [[ -n ${auth:-} ]]; then
		_[url]=${_[proto]}://$auth@${_[-name]}.git
	else
		_[url]=${_[proto]}://${_[-name]}.git
	fi

	_[dst]=${_[-prefix]}/${_[-name]}
}

