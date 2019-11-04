# cmd/src - Source management

# Get src from URL and enter to the directory
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

	src:enter_ "$@"
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

# Run src from URL
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

# cmd/src - Protected functions

src:cd_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	src:dst_ dst

	[[ -d $dst ]] || .die "Destination not found: $dst"

	.must -- pushd "$dst" >/dev/null

	# shellcheck disable=2128
	git.is.git . || .die "Not a git repository: $PWD"

	file.enter "${_[.dir]:-}"
}

src:dst_() {
	file:dst_ "$@"
}

src:enter_() {
	src:install_ "$@" >/dev/null

	# shellcheck disable=2128
	echo "$PWD"
}

src:exist_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	src:dst_ dst

	[[ -d $dst ]]
}

src:get_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	! src:exist_ "$dst" || .die "Destination already exist: $dst"

	local -a opt

	[[ -z ${_[-shallow]:-} ]] || opt+=(--depth 1)
	[[ -z ${_[.branch]:-}   ]] || opt+=(--branch "${_[.branch]}")

	_func_() {
		local repo=${url##*/}; repo=${repo%.*}

		.getting 'Cloning repository' git clone "${opt[@]}" "$url" "$repo"
		file:do_ copy "$repo" "$dst"
	}

	temp.inside _func_

	unset -f _func_
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

	src:cd_ "$dst"
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
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	src:cd_ "$dst"

	git.switch "${_[.branch]:-}"

	local -i expiry=${_[-expiry]:-3}
	if .expired "$expiry" "$(git.topdir)"/.git/FETCH_HEAD; then
		git.must.clean
		.getting 'Updating repository' git pull --quiet origin
	fi

	.must -- popd >/dev/null
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
