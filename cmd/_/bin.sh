# cmd/bin - Commands to manage programs/scripts

# Install program to path
bin:install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_USR"/bin
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
		[-prefix]="$_RUN"/bin
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

# bin - Private functions

bin.install-() {
	local url="${1?${FUNCNAME[0]}: missing argument}";    shift
	local prefix="${1?${FUNCNAME[0]}: missing argument}"; shift
	local name=${1:-}

	local -A bin=([url]="$url" [root]="$_RUN" [expiry]=-1)

	src.get bin

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

	src.del bin
}
