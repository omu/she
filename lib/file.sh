# file.sh - File related operations

file.download() {
	local    url=${1?${FUNCNAME[0]}: missing argument};                shift
	local -n file_download_dst_=${1?${FUNCNAME[0]}: missing argument}; shift

	local download
	temp.file download

	.getting "Downloading $url"
	.must -- http.get "$url" >"$download"
	.must -- chmod 644 "$download"

	# shellcheck disable=2034
	file_download_dst_=$download
}

file.enter() {
	local dir=${1:-}

	[[ -n $dir ]] || return 0

	if [[ -d $dir ]]; then
		.must -- cd "$dir"
	else
		dir=${dir%/*}
		[[ -d $dir ]] || .die "No path found to enter: $dir"
		.must -- cd "$dir"
	fi

	# shellcheck disable=2128
	echo "$PWD"
}

file.ln() {
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	src=$(realpath -m --relative-base "${dst%/*}" "$src")
	.must -- ln -sf "$src" "$dst"
}

file.run() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -f $file ]] || [[ $file =~ [.][^./]+$ ]] || file=$file.sh

	filetype.runnable "$file" || .die "File is not runnable: $file"

	local -a env=()
	flag.env_ env

	local -a argv=(env "${env[@]}")

	if [[ ! -x "$file" ]]; then
		if filetype.interpretable "$file"; then
			local -a shebang
			filetype.shebang "$file" shebang

			# shellcheck disable=2206
			argv+=("${shebang[@]}")
		fi
	fi

	argv+=("$file")

	"${argv[@]}"
}
