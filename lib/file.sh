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

	local url=${_[1]?missing value at [1]: url} dst=${_[2]:-${url##*/}}

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

	local dst=${_[1]?missing value at [1]: dst}

	file.chogm_ "$dst"
}

file.ln() {
	local src=${1?missing 1th argument: src} dst=${2?missing 2nd argument: dst}

	src=$(realpath -m --relative-base "${dst%/*}" "$src")
	must ln -sf "$src" "$dst"
}

file.enter() {
	local dir=${1:-}

	[[ -n $dir ]] || return 0

	if [[ -d $dir ]]; then
		must cd "$dir"
	elif [[ -f $dir ]]; then
		must cd "${dir%/*}"
	else
		die "No path found to enter: $dir"
	fi
}

# file.sh - Private functions

file._do_args_() {
	local op=${1?missing 1th argument: op}
	shift

	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
	)

	flag.parse "$@"

	local src=${_[1]?missing value at [1]: src} dst=${_[2]?missing value at [2]: dst}

	file.do_ "$op" "$src" "$dst"
}

file.do_() {
	local op=${1?missing 1th argument: op}
	local src=${2?missing 2nd argument: src}
	local dst=${3?missing 3rd argument: dst}

	[[ -e $src ]] || die "Source not found: $src"

	file.dst_ dst

	local dstdir
	if string.has_suffix_deleted dst /; then
		dstdir=$dst
	else
		dstdir=$dst
		path.dir dstdir
	fi

	[[ $dstdir = . ]] || must mkdir -p "$dstdir"

	case $op in
	copy)
		must cp -a "$src" "$dst"
		;;
	move)
		must mv -f "$src" "$dst"
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
	local -n file_dst_=${1?missing 1st argument: name reference}
	[[ -z ${_[-prefix]:-} ]] || file_dst_=${_[-prefix]}/$file_dst_
}

file.install_() {
	local url=${1?missing 1th argument: url}
	local dst=${2?missing 2nd argument: dst}

	local tempfile

	if [[ $url =~ ^[.]*/ ]]; then
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
	local dst=${1?missing 1th argument: dst}

	[[ -z ${_[-mode]:-}  ]] || must chmod "${_[-mode]}"  "$dst"
	[[ -z ${_[-owner]:-} ]] || must chown "${_[-owner]}" "$dst"
	[[ -z ${_[-group]:-} ]] || must chgrp "${_[-group]}" "$dst"
}
