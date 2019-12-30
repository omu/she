# cmd/src - Source management

# Fetch and chdir to source
src:enter() {
	# shellcheck disable=2192
	local -A _=(
		[-ttl]=-1
		[-cachedir]="${VOLATILE[src]}"
		[-tempdir]="${VOLATILE[tmp]}"

		[.help]='[-ttl=<minutes>] [-cachedir=<dir>] [-tempdir=<dir>] (<url> | <dir>)'
		[.argc]=1
	)

	flag.parse

	local url=$1
	shift

	src.enter "$url" _ && echo "$PWD"
}

# Fetch and instal source into a known source tree
src:install() {
	# shellcheck disable=2192
	local -A _=(
		[-enter]=false
		[-prefix]="${PERSISTENT[src]}"

		[.help]='[-prefix=<dir>] (<url> | <dir>)'
		[.argc]=1
	)

	flag.parse

	# shellcheck disable=2128
	local url=$1
	shift

	local -A src=()

	src.get "$url" src

	[[ ${src[class]:-} = git ]] || .die "Not a git repository: $url"

	local path="${src[domain]}"/"${src[name]}"
	local dst="${_[-prefix]}"/"$path"

	if [[ -d $dst ]]; then
		flag.true -enter || .bye "Already installed: $dst"
		.must -- pushd "$dst" >/dev/null && echo "$PWD"
	else
		file.cp "${src[cache]}" "$dst"  && echo "$PWD"
	fi
}

# Fetch source and run given command inside it
src:with() {
	# shellcheck disable=2192
	local -A _=(
		[-ttl]=-1
		[-cachedir]="${VOLATILE[src]}"
		[-tempdir]="${VOLATILE[tmp]}"

		[.help]='[-ttl=<minutes>] [-cachedir=<dir>] [-tempdir=<dir>] (<url> | <dir>) <command> [<arg>...]'
		[.argc]=2-
	)

	flag.parse

	local url=$1 old_pwd=$PWD
	shift

	src.enter "$url" _
	"$@" "${_[cache]}"
	.must -- cd "$old_pwd"
}
