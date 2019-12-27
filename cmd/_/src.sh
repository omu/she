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

	src.enter "$url" _
}

# Fetch and instal source into a known source tree
src:install() {
	# shellcheck disable=2192
	local -A _=(
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

	[[ -d $dst ]] || .die "Already installed: $dst"

	file.cp "${src[cache]}" "$dst"
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
