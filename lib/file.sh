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

	local url=${_[1]?missing value at [1]: url}

	_[url]=$url
	_[dst]=${_[2]:-${url##*/}}

	file.install_
}

# Copy file/directory to dstination creating all parents if necessary
file.copy() {
	file._do_args_ file.copy_ "$@"
}

# Move file/directory to destination creating all parents if necessary
file.move() {
	file._do_args_ file.move_ "$@"
}

# Link file/directory to dstination creating all parents if necessary
file.link() {
	file._do_args_ file.link_ "$@"
}

file.chogm() {
	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
	)

	flag.parse "$@"

	local file=${1?missing 1th argument: file}

	file.chogm_ "$file"
}

file.ln() {
	local src=${1?missing 1th argument: src} dst=${2?missing 2nd argument: dst}

	src=$(realpath -m --relative-base "${dst%/*}" "$src")
	must ln -sf "$src" "$dst"
}

# file.sh - Private functions

file._do_args_() {
	local func=${1?missing 1th argument: func}
	shift

	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
	)

	flag.parse "$@"

	_[src]=${_[1]?missing value at [1]: src} _[dst]=${_[2]?missing value at [2]: dst}

	file._do_ "$func"
}

file._do_() {
	local func=${1?missing 1th argument: func}
	shift

	[[ -e ${_[src]} ]] || die "Source not found: ${_[src]}"

	[[ -z ${_[-prefix]:-} ]] || _[dst]=${_[-prefix]}/${_[dst]}

	local dst=${_[dst]} dstdir

	if string.has_suffix_deleted dst /; then
		dstdir=$dst
	else
		dstdir=$dst
		path.dir dstdir
	fi

	_[dst]=$dst

	[[ $dstdir = . ]] || must mkdir -p "$dstdir"

	"$func"

	file.chogm_ "${_[dst]}"
}

file.install_() {
	local url=${_[url]?missing value: url} tempfile

	local tempfile

	if [[ $url =~ ^[.]*/ ]]; then
		_[src]=$url
	else
		temp.file tempfile
		http.get "$url" >"$tempfile"
		_[src]=$tempfile
	fi

	file._do_ file.copy_

	temp.clean tempfile
}

file.copy_() {
	must cp -a "${_[src]}" "${_[dst]}"
}

file.move_() {
	must mv -f "${_[src]}" "${_[dst]}"
}

file.link_() {
	file.ln "${_[src]}" "${_[dst]}"
}

file.chogm_() {
	local file=${1?missing 1th argument: file}

	[[ -z ${_[-mode]:-}  ]] || must chmod "${_[-mode]}"  "$file"
	[[ -z ${_[-owner]:-} ]] || must chown "${_[-owner]}" "$file"
	[[ -z ${_[-group]:-} ]] || must chgrp "${_[-group]}" "$file"
}
