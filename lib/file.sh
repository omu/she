# file.sh - File related operations

# file.install: Install file from URL
file.install() {
	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
	)

	flag.parse "$@"

	local url=${_[1]?${FUNCNAME[0]}: missing value}
	local dst=${_[2]:-${url##*/}}

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
	)

	flag.parse "$@"

	local dst=${_[1]?${FUNCNAME[0]}: missing value}

	file.chogm_ "$dst"
}

file.ln() {
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	src=$(realpath -m --relative-base "${dst%/*}" "$src")
	must.success ln -sf "$src" "$dst"
}

file.enter() {
	local dir=${1:-}

	[[ -n $dir ]] || return 0

	if [[ -d $dir ]]; then
		must.success cd "$dir"
	else
		dir=${dir%/*}
		[[ -d $dir ]] || die "No path found to enter: $dir"
		must.success cd "$dir"
	fi
}

file.download() {
	local    url=${1?${FUNCNAME[0]}: missing argument};                shift
	local -n file_download_dst_=${1?${FUNCNAME[0]}: missing argument}; shift

	local tempfile

	temp.file tempfile
	must.success http.get "$url" >"$tempfile"

	# shellcheck disable=2034
	file_download_dst_=$tempfile
}

# file.sh - Private functions

file._do_args_() {
	local op=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
	)

	flag.parse "$@"

	local src=${_[1]?${FUNCNAME[0]}: missing value}
	local dst=${_[2]?${FUNCNAME[0]}: missing value}

	file.do_ "$op" "$src" "$dst"
}

file.do_() {
	local op=${1?${FUNCNAME[0]}: missing argument};  shift
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -e $src ]] || die "Source not found: $src"

	file.dst_ dst

	local dstdir
	if string.has_suffix_deleted dst /; then
		dstdir=$dst
	else
		dstdir=$dst
		path.dir dstdir
	fi

	[[ $dstdir = . ]] || must.success mkdir -p "$dstdir"

	case $op in
	copy)
		must.success cp -a "$src" "$dst"
		;;
	move)
		must.success mv -f "$src" "$dst"
		;;
	link)
		file.ln "$src" "$dst"
		;;
	*)
		bug "Unrecognized operation: $op"
		;;
	esac

	file._chogm_ "$dst"
}

file.dst_() {
	local -n file_dst_=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -z ${_[-prefix]:-} ]] || file_dst_=${_[-prefix]}/$file_dst_
}

file.install_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	local tempfile=

	if url.is "$url" local; then
		src=$url
	else
		temp.file tempfile
		http.get "$url" >"$tempfile"
		src=$tempfile
	fi

	file.do_ copy "$src" "$dst"

	temp.clean tempfile
}

file._chogm_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -z ${_[-mode]:-}  ]] || must.success chmod "${_[-mode]}"  "$dst"
	[[ -z ${_[-owner]:-} ]] || must.success chown "${_[-owner]}" "$dst"
	[[ -z ${_[-group]:-} ]] || must.success chgrp "${_[-group]}" "$dst"
}
