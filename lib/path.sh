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

	path.normalize path_dir_

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
	local ext=${2:-}

	path_base_=${path_base_##*/}
}

path.name() {
	local -n path_name_=${1?missing 1th argument: name reference}
	local ext=${2:-}

	path_name_=${path_name_##*/}
	path_name_=${path_name_%.*}
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

path.subext() {
	local -n path_subext_=${1?missing 1th argument: name reference}
	local ext=${2?missing 2nd argument: ext}

	case $path_subext_ in
	*.*)
		path_subext_=${path_subext_%.*}
		path_subext_=${path_subext_}.${ext}
		;;
	*)
		;;
	esac
}

# shellcheck disable=2034
path.parse() {
	local -n path_parse_=_
	if [[ ${1:-} = -A ]]; then
		shift
		path_parse_=${1?missing argument for -A: hash reference}
	fi

	local path=${1?missing 1th argument: path}

	local dir=$path base=$path name=$path ext=$path

	path.dir dir
	path.base base
	path.name name
	path.ext ext

	path_parse_[.dir]=$dir
	path_parse_[.base]=$base
	path_parse_[.name]=$name
	path_parse_[.ext]=$ext

	if [[ -n $ext ]]; then
		path_parse_[.dotext]=.$ext
	else
		path_parse_[.dotext]=$ext
	fi
}

path.suffixize() {
	local -n path_suffixize_=${1?missing 1th argument: name reference}
	local suffix=${2?missing 2nd argument: suffix}

	local -A _
	path.parse "$path_suffixize_"

	printf -v path_suffixize_ "%s/%s${suffix}%s" "${_[.dir]:-.}" "${_[.name]}" "${_[.dotext]}"
}

path.normalize() {
	local -n path_normalize_=${1?missing 1th argument: name reference}

	while [[ $path_normalize_ =~ //+ ]]; do
		path_normalize_=${path_normalize_/\/\//\/}
	done
}
