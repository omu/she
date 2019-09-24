# path.sh - Path management

path.is_volatile() {
	df -t tmpfs "$1" &>/dev/null
}

path.is_equal() {
	[[ $(realpath -m "$1") = $(realpath -m "$2") ]]
}

path.is_inside() {
	local given=$1 path=$2

	local relative
	relative=$(realpath --relative-to "$given" "$path" 2>/dev/null) || return

	[[ ! $relative =~ ^[.] ]]
}

path.dir() {
	local -n path_dir_=${1?missing 1th argument: name reference}

	case $path_dir_ in
	*/*)
		path_dir_=${path_dir_%/*}
		[[ -n $path_dir_ ]] || path_dir_=/
		;;
	*)
		path_dir_=.
		;;
	esac
}

path.base() {
	local -n path_base_=${1?missing 1th argument: name reference}

	path_base_=${path_base_##*/}
}

path.ext() {
	local -n path_ext_=${1?missing 1th argument: name reference}

	path_ext_=${path_ext_##*/}

	case $path_ext_ in
	*.*)
		path_ext_=${path_ext_##*.}
		;;
	*)
		path_ext_=
		;;
	esac
}

path.ext_change() {
	local -n path_ext_change_=${1?missing 1th argument: name reference}
	local ext=${2?missing 2nd argument: ext}

	case $path_ext_change_ in
	*.*)
		path_ext_change_=${path_ext_change_%.*}
		path_ext_change_=${path_ext_change_}${ext}
		;;
	*)
		;;
	esac
}
