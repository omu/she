# cmd/src - Source management

# Get src from URL and enter to the directory
dir:enter() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=
		[-prefix]="$_RUN"/src
		[-shallow]=false

		[.help]='[-(expiry=MINUTES|prefix=DIR|shallow=BOOL)] URL'
		[.argc]=1
	)

	flag.parse

	dir:enter_ "$@"
}

# Run command inside src
dir:inside() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=-1
		[-prefix]="$_RUN"/src
		[-pwd]=
		[-shallow]=false

		[.help]='[-expiry=MINUTES|-prefix=DIR|-pwd=DIR|-shallow=BOOL] URL COMMAND [ARG]...'
		[.argc]=2-
	)

	flag.parse

	local url=$1 old_pwd=$PWD
	shift

	dir:install_ "$url"

	"$@"

	.must -- cd "$old_pwd"
}

# Install src into a source tree
dir:install() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=
		[-prefix]="$_USR"/src

		[.help]='[-(expiry=MINUTES|prefix=DIR)] URL'
		[.argc]=1
	)

	flag.parse

	dir:install_ "$@"
}

# Run src from URL
dir:run() {
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

	dir:install_ "$@"

	dir:run_ "${_[.dir]}"
}

# Install src into a volatile source tree
dir:use() {
	# shellcheck disable=2192
	local -A _=(
		[-expiry]=
		[-prefix]="$_RUN"/src
		[-shallow]=false

		[.help]='[-(expiry=MINUTES|prefix=DIR|shallow=BOOL)] URL'
		[.argc]=1
	)

	flag.parse

	dir:install_ "$@"
}

# cmd/src - Protected functions

dir:cd_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	dir:dst_ dst

	[[ -d $dst ]] || .die "Destination not found: $dst"

	.must -- pushd "$dst" >/dev/null

	# shellcheck disable=2128
	git.is.git . || .die "Not a git repository: $PWD"

	file.enter "${_[.dir]:-}"
}

dir:dst_() {
	file:dst_ "$@"
}

dir:enter_() {
	dir:install_ "$@" >/dev/null

	# shellcheck disable=2128
	echo "$PWD"
}

dir:exist_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	dir:dst_ dst

	[[ -d $dst ]]
}

dir:get_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	! dir:exist_ "$dst" || .die "Destination already exist: $dst"

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

dir:install_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	url:parse_ "$url" || .die "Error parsing URL: ${_[!]}: $url"

	dir:plan_ || .die "Error planning URL: ${_[!]}: $url"

	local src=${_[1]} dst=${_[2]:-}

	if dir:exist_ "$dst"; then
		dir:update_ "$dst"
	else
		dir:get_ "$src" "$dst"
	fi

	dir:cd_ "$dst"
}

dir:managed_() {
	local path=${1?${FUNCNAME[0]}: missing argument}; shift

	git.is.git "$path" && git -C "$path" config underscore.name &>/dev/null
}

dir:run_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	path.base file

	.calling "$file" file:run_ "$file"
}

dir:update_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	dir:cd_ "$dst"

	git.switch "${_[.branch]:-}"

	local -i expiry=${_[-expiry]:-3}
	if .expired "$expiry" "$(git.topdir)"/.git/FETCH_HEAD; then
		git.must.clean
		.getting 'Updating repository' git pull --quiet origin
	fi

	.must -- popd >/dev/null
}

dir:plan_() {
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
