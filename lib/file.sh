# file.sh - File related operations

file.download() {
	local    url=${1?${FUNCNAME[0]}: missing argument};                shift
	local -n file_download_dst_=${1?${FUNCNAME[0]}: missing argument}; shift

	local download
	temp.file download

	.ncat "$url" >"$download"
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

file.run() {
	# shellcheck disable=2034
	local -A file_run_env_=()

	file.run- file_run_env_ "$@"
}

file.rune() {
	file.run- "$@"
}

# file - Private functions

file.run-() {
	local -n file_env_=${1?${FUNCNAME[0]}: missing argument}; shift
	local file=${1?${FUNCNAME[0]}: missing argument};         shift

	[[ -f $file ]] || [[ $file =~ [.][^./]+$ ]] || file=$file.sh

	filetype.runnable "$file" || .die "File is not runnable: $file"

	local -a argv=()

	[[ ${#file_env_[@]} -eq 0 ]] || argv+=(env "${file_env_[@]}")

	if [[ ! -x "$file" ]]; then
		if filetype.interpretable "$file"; then
			local -a shebang
			filetype.shebang "$file" shebang

			case ${shebang[0]} in
			*/env)
				[[ ${#file_env_[@]} -eq 0 ]] || argv+=("${shebang[@]:1}")
				;;
			*)
				# shellcheck disable=2206
				argv+=("${shebang[@]}")
				;;
			esac
		fi
	fi

	argv+=("$file" "$@")

	"${argv[@]}"
}
