# file.sh - File related operations

# Install file from URL
file.install() {
	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
		[-quiet]=

		[.help]='[-(group|mode|owner|prefix)=VALUE] URL [FILE]'
		[.argc]=1-
	)

	flag.parse

	local url=$1 dst=${2:-${1##*/}}

	file.install_ "$url" "$dst"
}

# Copy file/directory to dstination creating all parents if necessary
file.copy() {
	file._do_args_ copy "$@"
}

# Move file/directory to destination creating all parents if necessary
file.move() {
	file._do_args_ move "$@"
}

# Link file/directory to dstination creating all parents if necessary
file.link() {
	file._do_args_ link "$@"
}

file.chogm() {
	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=

		[.help]='[-(group|mode|owner)=VALUE] URL [FILE]'
		[.argc]=1-
	)

	flag.parse

	local dst=$1

	file.chogm_ "$dst"
}

# Run program
file.run() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='URL|FILE'
		[.argc]=1
	)

	flag.parse

	# shellcheck disable=1007
	local file temp_file_run=

	if url.is "$url" web; then
		file.download "$url" temp_file_run
		file=$temp_file_run

		if filetype.is "$file" runnable; then
			.must -- chmod +x "$file"
		fi
	elif url.is "$url" local; then
		file=$url
	else
		.die "Unsupported URL: $url"
	fi

	.running 'Running file'

	local err
	file.run_ "$file" || err=$? && err=$?

	temp.clean temp_file_run

	return "$err"
}

# file - Protected functions

file.ln() {
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	src=$(realpath -m --relative-base "${dst%/*}" "$src")
	.must -- ln -sf "$src" "$dst"
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
}

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

file.do_() {
	local op=${1?${FUNCNAME[0]}: missing argument};  shift
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -e $src ]] || .die "Source not found: $src"

	file.dst_ dst

	local dstdir
	if string.has_suffix_deleted dst /; then
		dstdir=$dst
	else
		dstdir=$dst
		path.dir dstdir
	fi

	[[ $dstdir = . ]] || .must -- mkdir -p "$dstdir"

	local installed=$dst/${src##*/}

	case $op in
	copy)
		.must -- cp -a "$src" "$dst"
		;;
	move)
		.must -- mv -f "$src" "$dst"
		;;
	link)
		file.ln "$src" "$dst"
		;;
	*)
		.bug "Unrecognized operation: $op"
		;;
	esac

	flag.true -quiet || .ok "$installed"

	file._chogm_ "$installed"

	_[.]=$installed
}

file.dst_() {
	local -n file_dst_=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -z ${_[-prefix]:-} ]] || file_dst_=${_[-prefix]}/$file_dst_
}

file.install_() {
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	if url.is "$src" web; then
		file.download "$src" src
		file.do_ copy "$src" "$dst"
		temp.clean src
	else
		file.do_ copy "$src" "$dst"
	fi
}

file.run_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	filetype.is "$file" runnable || .die "File is not runnable: $file"

	local -a run_env_=()
	flag.env_ run_env_

	local -a run_cmd_=(env "${run_env_[@]}")

	if [[ ! -x "$file" ]]; then
		if filetype.is "$file" interpretable; then
			local -a shebang
			filetype.shebang_ "$file" shebang

			# shellcheck disable=2206
			run_cmd_+=("${shebang[@]}")
		fi
	fi

	run_cmd_+=("$file")

	"${run_cmd_[@]}"
}

# file - Private functions

file._do_args_() {
	local op=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=

		[.help]='[-(GROUP|MODE|OWNER|PREFIX)=VALUE] SRC [DST]'
		[.argc]=1-
	)

	flag.parse

	local src=$1 dst=$2

	file.do_ "$op" "$src" "$dst"
}

file._chogm_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -z ${_[-mode]:-}  ]] || .must -- chmod "${_[-mode]}"  "$dst"
	[[ -z ${_[-owner]:-} ]] || .must -- chown "${_[-owner]}" "$dst"
	[[ -z ${_[-group]:-} ]] || .must -- chgrp "${_[-group]}" "$dst"
}
