# src.sh - Source management

# src.install: Install to a known location
src.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_USR"/src
		[-expiry]=
	)

	flag.parse "$@"

	src.install_
}

# src.use: Install src into the runtime tree
src.use() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_RUN"/src
		[-shallow]=
		[-expiry]=
	)

	flag.parse "$@"

	src.install_
}

# enter: Get src from URL and enter to the directory
src.enter() {
	src.use "$@" >/dev/null

	echo "$PWD"
}

# run: Run src from URL
src.run() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_RUN"/src
		[-shallow]=
		[-expiry]=-1
		[-pwd]=
		[-test]=
	)

	flag.parse "$@"

	src.install_

	src.run_ "${_[.dir]}"
	flag.false test || src.test_ "${_[.dir]}"
}

src.managed_() {
	local path=${1?missing 1th argument: path}

	git.is_git "$path" && git -C "$path" config underscore.name &>/dev/null
}

src.install_() {
	local url=${_[1]?missing value at [1]: url}

	url.parse "$url" || die "Error parsing URL: ${_[.error]}: $url"

	src._plan_ || die "Error planning URL: ${_[.error]}: $url"

	local src=${_[1]} dst=${_[2]}

	if src.exist_ "$dst"; then
		src.update_ "$dst"
	else
		src.get_ "$src" "$dst"
	fi

	src.enter_ "$dst"
}

src.run_() {
	local file=${1?missing 1st argument: file}

	path.base file
	src.exe_ "$file"
}

src.test_() {
	local file=${1?missing 1st argument: file}

	local test_file=$file
	path.suffixize test_file '_test'

	src.run_ "$test_file"
}

src.exe_() {
	local file=${1?missing 1st argument: file}

	local -a env
	src.env_ env

	if [[ -x $file ]]; then
		env "${env[@]}" "$file"
	else
		src.interprete "$file" "${env[@]}"
	fi
}

src.interprete() {
	local file=${1?missing 1st argument: file}
	shift

	local ext=$file
	path.ext ext

	if [[ -z $ext ]]; then
		# shellcheck disable=2209
		ext=sh
		file=$file.$ext
	fi

	[[ -f $file ]] || die "Not file found to interprete: $file"

	local interpreter
	case $ext in
	sh|"") interpreter=bash    ;;
	rb)    interpreter=ruby    ;;
	py)    interpreter=python  ;;
	pl)    interpreter=perl    ;;
	js)    interpreter=node    ;;
	php)   interpreter=php     ;;
	*)     die "Unsupported interpreter for extension: $ext" ;;
	esac

	env "$@" "$interpreter" "$file"
}

src.env_() {
	# shellcheck disable=2034
	local -n src_env_=${1?missing 1st argument: array reference}

	flag.env src_env_
}

src._plan_() {
	local owner repo auth path

	if [[ ! ${_[.host]} =~ ^(github.com|gitlab.com|bitbucket.com)$ ]]; then
		_[.error]='unsupported provider'
		return 1
	fi

	path=${_[.path]:-}

	if [[ ! $path =~ [^/]+/[^/]+ ]]; then
		_[.error]='incomplete url'
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
