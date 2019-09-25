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

# enter: Get src from URL and enter to the directory
src.enter() {
	src.use "$@" >/dev/null

	echo "$PWD"
}

src.managed_() {
	local path=${1?missing 1th argument: path}

	git.is_git "$path" && git -C "$path" config underscore.name &>/dev/null
}

src.install_() {
	local url=${_[1]?missing value at [1]: url}

	url.parse "$url" || die "Error parsing URL: ${_[error]}: $url"

	src._plan_ || die "Error planning URL: ${_[error]}: $url"

	local src=${_[1]} dst=${_[2]}

	if src.exist_ "$dst"; then
		src.update_ "$dst"
	else
		src.get_ "$src" "$dst"
	fi

	src.enter_ "$dst"
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
		_[1]=${_[proto]}://$auth@${_[name]}.git
	else
		_[1]=${_[proto]}://${_[name]}.git
	fi

	_[2]=${_[name]}
}

src.dst_() {
	git.dst_ "$@"
}

src.exist_() {
	git.exist_ "$@"
}

src.get_() {
	git.clone_ "$@"
}

src.update_() {
	git.update_ "$@"
}

src.enter_() {
	git.enter_ "$@"
}
