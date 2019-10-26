# bin.sh - Executable files

# Install program to path
bin.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_USR"/bin
		[-name]=

		[.help]='URL|FILE'
		[.argc]=1
	)

	flag.parse

	bin.install_ "$@"
}

# Use program
bin.use() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_RUN"/bin
		[-name]=

		[.help]='URL|FILE'
		[.argc]=1
	)

	flag.parse

	bin.install_ "$@"
}

# bin - Protected functions

bin.install_() {
	local url="${1?${FUNCNAME[0]}: missing argument}"; shift

	# shellcheck disable=1007
	local bin= temp_bin_file= temp_bin_dir=

	if url.getable url; then
		file.download "$url" temp_bin_file
		bin=$temp_bin_file
	else
		bin=$url
	fi

	if filetype.is "$bin" compressed; then
		temp.dir temp_bin_dir

		zip.unpack -force=true "$bin" "$temp_bin_dir"
		bin=$temp_bin_dir
	fi

	local -a bins=()
	bin._inspect "$bin" bins

	if [[ ${#bins[@]} -eq 1 ]]; then
		local src=${bins[0]} dst=${_[-name]:-}

		file.install -prefix="${_[-prefix]}" -mode=755 "$src" "$dst"
	elif [[ ${#bins[@]} -gt 1 ]]; then
		[[ -n ${_[-name]:-} ]] || .die "Ambiguous usage of name argument: ${_[-name]}"

		local src
		for src in "${bins[@]}"; do
			file.install -prefix="${_[-prefix]}" -mode=755 "$src"
		done
	else
		.die "No program found: $url"
	fi

	temp.clean temp_bin_file temp_bin_dir
}

# bin - Private functions

bin._inspect() {
	local    bin=${1?${FUNCNAME[0]}: missing argument};          shift
	local -n bin_inspect_=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ -d $bin ]]; then
		local file
		for file in "$bin"/*; do
			filetype.is "$file" program || continue
			bin_inspect_+=("$file")
		done
	elif filetype.is "$bin" program; then
		bin_inspect_+=("$file")
	fi
}
