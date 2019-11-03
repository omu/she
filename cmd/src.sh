# src.sh - Source management

# Get src from url and enter to the directory
src:enter() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=
		[-prefix]="$_RUN"/src
		[-shallow]=false

		[.help]='[-(expiry=MINUTES|prefix=DIR|shallow=BOOL)] URL'
		[.argc]=1
	)

	flag.parse

	src:install_ "$@" >/dev/null

	# shellcheck disable=2128
	echo "$PWD"
}

# Install src into a source tree
src:install() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=
		[-prefix]="$_USR"/src

		[.help]='[-(expiry=MINUTES|prefix=DIR)] URL'
		[.argc]=1
	)

	flag.parse

	src:install_ "$@"
}

# Run src from url
src:run() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=-1
		[-prefix]="$_RUN"/src
		[-pwd]=
		[-shallow]=false

		[.help]='[-expiry=MINUTES|-prefix=DIR|-pwd=DIR|-shallow=BOOL] URL'
		[.argc]=1
	)

	flag.parse

	src:install_ "$@"

	src:run_ "${_[.dir]}"
}

# Install src into a volatile source tree
src:use() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=
		[-prefix]="$_RUN"/src
		[-shallow]=false

		[.help]='[-(expiry=MINUTES|prefix=DIR|shallow=BOOL)] URL'
		[.argc]=1
	)

	flag.parse

	src:install_ "$@"
}

# src - Protected functions

src:dst_() {
	git:dst_ "$@"
}

src:enter_() {
	git:enter_ "$@"
}

src:exist_() {
	git:is:exist_ "$@"
}

src:get_() {
	git:clone_ "$@"
}

src:install_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	url:parse_ "$url" || .die "Error parsing URL: ${_[!]}: $url"

	src:plan_ || .die "Error planning URL: ${_[!]}: $url"

	local src=${_[1]} dst=${_[2]:-}

	if src:exist_ "$dst"; then
		src:update_ "$dst"
	else
		src:get_ "$src" "$dst"
	fi

	src:enter_ "$dst"
}

src:managed_() {
	local path=${1?${FUNCNAME[0]}: missing argument}; shift

	git.is.git "$path" && git -C "$path" config underscore.name &>/dev/null
}

src:run_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	path.base file

	.calling "$file" file:run_ "$file"
}

src:update_() {
	git.update_ "$@"
}

src:plan_() {
	local owner repo auth path

	if [[ ! ${_[.host]} =~ ^(github.com|gitlab.com|bitbucket.com)$ ]]; then
		_[!]='unsupported provider'
		return 1
	fi

	path=${_[.path]:-}

	if [[ ! $path =~ [^/]+/[^/]+ ]]; then
		_[!]='incomplete url'
		return 1
	fi

	if [[ $path =~ @.*$ ]]; then
		_[.branch]=${path#*@}; path=${path%@*}
		_[.path]=$path
	fi

	owner=${path%%/*}; path=${path#*/}

	_[.dir]=
	if [[ $path = */* ]]; then
		_[.dir]=${path#*/}; path=${path%%/*}
	fi

	repo=${path%.git}

	_[.name]=${_[.host]}/$owner/$repo

	if [[ ${_[.proto]} == https ]] && [[ -n ${HTTPS_TOKEN:-} ]]; then
		auth="${HTTPS_TOKEN}:x-oauth-basic"
	else
		auth=${_[.userinfo]}
	fi

	if [[ -n ${auth:-} ]]; then
		_[1]=${_[.proto]}://$auth@${_[.name]}.git
	else
		_[1]=${_[.proto]}://${_[.name]}.git
	fi

	_[2]=${_[.name]}
}
