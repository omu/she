# bin.sh - Executable files

# Install program to path
bin.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_USR"/bin
		[-name]=

		[.help]='[-name=NAME] [-prefix=DIR] URL|FILE'
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

		[.help]='[-name=NAME] [-prefix=DIR] URL|FILE'
		[.argc]=1
	)

	flag.parse

	bin.install_ "$@"
}

# Run program
bin.run() {
	# shellcheck disable=2192
	local -A _=(
		[-name]=

		[.help]='[-name=NAME] URL|FILE'
		[.argc]=1
	)

	flag.parse

	_[-prefix]="$_RUN/tmp"
	_[-quiet]=true

	bin.install_ "$@"

	local file=${_[.]:-}
	[[ -n $file ]] || .bug 'No file installed'

	.running 'Running downloaded file'

	local err
	src.exe_ "$file" || err=$? && err=$?

	rm -f "$file"

	return "$err"
}

# bin - Protected functions

bin.install_() {
	local url="${1?${FUNCNAME[0]}: missing argument}"; shift

	# shellcheck disable=1007
	local bin= temp_bin_file= temp_bin_dir=

	if url.is "$url" web; then
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

	[[ -n ${_[-mode]:-} ]] || _[-mode]=755

	if [[ ${#bins[@]} -eq 1 ]]; then
		local src=${bins[0]} dst=${_[-name]:-}

		file.install_ "$src" "$dst"
	elif [[ ${#bins[@]} -gt 1 ]]; then
		[[ -n ${_[-name]:-} ]] || .die "Ambiguous usage of name argument: ${_[-name]}"

		local src
		for src in "${bins[@]}"; do
			file.install_ "$src"
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
		bin_inspect_+=("$bin")
	fi
}
