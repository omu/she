# bin.sh - Executable files

# bin.install: Install program to path
bin.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_USR"/bin
		[-name]=

		[.help]='url|file'
		[.argc]=1
	)

	flag.parse "$@"
	bin.install_
}

# bin.use: Use program
bin.use() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_RUN"/bin
		[-name]=

		[.help]='url|file'
		[.argc]=1
	)

	flag.parse "$@"
	bin.install_
}

# bin.sh - Protected functions

bin.install_() {
	local url=${_[1]}

	# shellcheck disable=1007
	local bin= tempfile= tempdir=

	if [[ $url =~ ^[.]*/ ]]; then
		bin=$url
	else
		file.download tempfile
		bin=$tempfile
	fi

	if is.file compressed "$bin"; then
		zip.unpack "$bin" tempdir
		bin=$tempdir
	fi

	local -a bins
	bin._inspect "$bin" bins

	if [[ ${#bins[@]} -eq 1 ]]; then
		local src=${bins[0]} dst=${_[-name]:-}

		file.install -prefix="${_[-prefix]}" -mode=755 "$src" "$dst"
	elif [[ ${#bins[@]} -gt 1 ]]; then
		[[ -n ${_[-name]:-} ]] || die "Ambiguous usage of name argument: ${_[-name]}"

		local src
		for src in "${bins[@]}"; do
			file.install -prefix="${_[-prefix]}" -mode=755 "$src"
		done
	else
		die "No program found: $url"
	fi

	temp.clean tempfile tempdir
}

# bin.sh - Private functions

bin._inspect() {
	local    bin=${1?${FUNCNAME[0]}: missing argument};          shift
	local -n bin_inspect_=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ -d $bin ]]; then
		local file
		for file in "$bin"/*; do
			is.file program "$file" || continue
			bin_inspect_+=("$file")
		done
	elif is.file program "$bin"; then
		bin_inspect_+=("$file")
	fi
}
