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
