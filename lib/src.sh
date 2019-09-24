# src.sh - Source management

# src.install: Install to a known location
src.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_USR"/src
		[-shallow]=
	)

	flag.parse "$@"

	src.install_
}

# src.use: Install src into the runtime tree
src.use() {
	src.install -prefix="$_RUN"/src "$@"
}

# enter: Get files from URL and chdir to directory
src.enter() {
	src.use "$@" >/dev/null

	[[ -n ${_[dir]:-} ]] || return 0

	if [[ -d ${_[dir]} ]]; then
		must cd "${_[dir]}"
	elif [[ -f ${_[dir]} ]]; then
		must cd "${_[dir]%/*}"
	else
		die "No path found: ${_[name]}: ${_[dir]}"
	fi

	echo "$PWD"
}

src.is_managed_path() {
	local path=${1?missing 1th argument: path}

	git.is_git "$path" && git -C "$path" config underscore.name &>/dev/null
}

src.install_() {
	local url=${_[1]?missing value at [1]: url}

	url.parse "$url" || die "Error parsing URL: ${_[error]}: $url"

	src._plan_ || die "Error planning URL: ${_[error]}: $url"

	if [[ ! -d ${_[dst]} ]]; then
		git.clone_
	else
		git.refresh_
	fi
}

src._plan_() {
	local owner repo auth path

	if [[ ! ${_[host]} =~ ^(github.com|gitlab.com|bitbucket.com)$ ]]; then
		_[error]='unsupported provider'
		return 1
	fi

	path=${_[path]:-}

	if [[ ! $path =~ [^/]+/[^/]+ ]]; then
		_[error]='incomplete url'
		return 1
	fi

	if [[ $path =~ @.*$ ]]; then
		_[branch]=${path#*@}; path=${path%@*}
		_[path]=$path
	fi

	owner=${path%%/*}; path=${path#*/}

	_[dir]=
	if [[ $path = */* ]]; then
		_[dir]=${path#*/}; path=${path%%/*}
	fi

	repo=${path%.git}

	_[name]=${_[host]}/$owner/$repo

	if [[ ${_[proto]} == https ]] && [[ -n ${HTTPS_TOKEN:-} ]]; then
		auth="${HTTPS_TOKEN}:x-oauth-basic"
	else
		auth=${_[userinfo]}
	fi

	if [[ -n ${auth:-} ]]; then
		_[url]=${_[proto]}://$auth@${_[name]}.git
	else
		_[url]=${_[proto]}://${_[name]}.git
	fi

	_[dst]=${_[-prefix]}/${_[name]}
}
