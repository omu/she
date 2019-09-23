# file.sh - File related operations

# file.install: Install file from URL
file.install() {
	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
		[-smart]=
	)

	flag.parse "$@"

	local url=${_[1]?missing value for: url}

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

	local file=${1?missing argument: file}

	file.chogm_ "$file"
}

# file.sh - Protected function

file.ln() {
	local src=${1?missing argument: src} dst=${2?missing argument: dst}

	src=$(realpath -m --relative-base "${dst%/*}" "$src")
	must ln -sf "$src" "$dst"
}

# file.sh - Private functions

file._do_args_() {
	local func=${1?missing argument: func}
	shift

	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
		[-smart]=
	)

	flag.parse "$@"

	_[src]=${_[1]?missing value: src} _[dst]=${_[2]?missing value: dst}

	file._do_ "$func"
}

file._do_() {
	local func=${1?missing value: func}
	shift

	[[ -e ${_[src]} ]] || die "Source not found: ${_[src]}"

	[[ -z ${_[-prefix]:-} ]] || _[dst]=${_[-prefix]}/${_[dst]}

	local dstdir

	if string.has_suffix_deleted dst /; then
		dstdir=${_[dst]}
	else
		dstdir=${_[dst]%/*}
	fi

	must mkdir -p "$dstdir"

	_[dstdir]=$dstdir

	"$func"

	file.chogm_ "${_[dst]}"
}

file.install_() {
	local url=${_[url]?missing value for: url} tempfile

	if [[ ! $url =~ ^[.]*/ ]]; then
		temp.file tempfile
		http.get "$url" >"$tempfile"
		_[src]=$tempfile
	else
		_[src]=$url
	fi

	file._do_ file.copy_

	temp.clean tempfile
}

file.copy_() {
	if flag.true smart && path.is_volatile "${_[dstdir]}"; then
		file.ln "${_[src]}" "${_[dst]}"
	else
		must cp -a "${_[src]}" "${_[dst]}"
	fi
}

file.move_() {
	must mv -f "${_[src]}" "${_[dst]}"
}

file.link_() {
	file.ln "${_[src]}" "${_[dst]}"
}

file.chogm_() {
	local file=${1?missing argument: file}

	[[ -z ${_[-mode]:-}  ]] || must chmod "${_[-mode]}"  "$file"
	[[ -z ${_[-owner]:-} ]] || must chown "${_[-owner]}" "$file"
	[[ -z ${_[-group]:-} ]] || must chgrp "${_[-group]}" "$file"
}
