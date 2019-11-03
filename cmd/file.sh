# file.sh - File related operations

# Change owner, group and mode
file:chogm() {
	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=

		[.help]='[-group=GROUP|mode=MODE|owner=USER] URL [FILE]'
		[.argc]=1-
	)

	flag.parse

	local dst=$1

	file.chogm_ "$dst"
}

# Copy file/directory to dstination creating all parents if necessary
file:copy() {
	file:do_args_ copy "$@"
}

# Install file from URL
file:install() {
	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
		[-quiet]=

		[.help]='[-group=GROUP|mode=MODE|owner=USER|prefix=DIR|quiet=BOOL] URL [FILE]'
		[.argc]=1-
	)

	flag.parse

	local url=$1 dst=${2:-${1##*/}}

	file:install_ "$url" "$dst"
}

# Link file/directory to dstination creating all parents if necessary
file:link() {
	file:do_args_ link "$@"
}

# Move file/directory to destination creating all parents if necessary
file:move() {
	file:do_args_ move "$@"
}

# Run program
file:run() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='URL|FILE'
		[.argc]=1
	)

	flag.parse

	file:run_ "$@"
}

# file - Protected functions

file:chogm_() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -z ${_[-mode]:-}  ]] || .must -- chmod "${_[-mode]}"  "$dst"
	[[ -z ${_[-owner]:-} ]] || .must -- chown "${_[-owner]}" "$dst"
	[[ -z ${_[-group]:-} ]] || .must -- chgrp "${_[-group]}" "$dst"
}

file:do_() {
	local op=${1?${FUNCNAME[0]}: missing argument};  shift
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -e $src ]] || .die "Source not found: $src"

	file:dst_ dst

	local dstdir
	if string.has_suffix_deleted dst /; then
		dstdir=$dst
	else
		dstdir=$dst
		path.dir dstdir
	fi

	[[ $dstdir = . ]] || .must -- mkdir -p "$dstdir"

	local done=$dstdir/${src##*/}

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

	flag.true -quiet || .ok "$done"

	file:chogm_ "$done"

	_[.]=$done
}

file:do_args_() {
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

	file:do_ "$op" "$src" "$dst"
}

file:dst_() {
	local -n file_dst_=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ -z ${_[-prefix]:-} ]] || file_dst_=${_[-prefix]}/$file_dst_
}

file:install_() {
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	if url.is "$src" web; then
		file.download "$src" src
		file:do_ copy "$src" "$dst"
		temp.clean src
	else
		file:do_ copy "$src" "$dst"
	fi
}

file:run_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

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
	file.run "$file" || err=$? && err=$?

	temp.clean temp_file_run

	return "$err"
}
