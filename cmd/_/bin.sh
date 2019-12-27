# cmd/bin - Commands to manage programs/scripts

# Install program to path
bin:install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="${PERSISTENT[bin]}"
		[-name]=

		[.help]='[-name=<name>] [-prefix=<dir>] (<url> | <file>)'
		[.argc]=1
	)

	flag.parse

	# shellcheck disable=2128
	local url=$1
	shift

	bin.install- "$url" "${_[-prefix]}" "${_[-name]:-}"
}

# Use program by installing to a volatile path
bin:use() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="${VOLATILE[bin]}"
		[-name]=

		[.help]='[-name=<name>] [-prefix=<dir>] (<url> | <file>)'
		[.argc]=1
	)

	flag.parse

	# shellcheck disable=2128
	local url=$1
	shift

	bin.install- "$url" "${_[-prefix]}" "${_[-name]:-}"
}

# cmd/bin - Private functions

bin.install-() {
	local url="${1?${FUNCNAME[0]}: missing argument}";    shift
	local prefix="${1?${FUNCNAME[0]}: missing argument}"; shift
	local name=${1:-}

	local -A bin=([ttl]=-1)

	src.get "$url" bin

	local -a bins=()
	filetype.runnables "${bin[cache]}" bins

	[[ ${#bins[@]} -gt 0 ]] || .die "No program found: $url"

	if [[ -n $name ]] && [[ ${#bins[@]} -gt 1 ]]; then
		.die "Ambiguous usage of name option: $name"
	fi

	local src
	for src in "${bins[@]}"; do
		[[ -z $name ]] || name=${src##*/}

		file.cp "$src" "$prefix"/"$name" 0755
	done

	src.del "$url" bin
}
