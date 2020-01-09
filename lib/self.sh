# self.sh - Functions related to program itself

self.name() {
	# shellcheck disable=2128
	echo "$PROGNAME"
}

self.path() {
	local self

	self=${BASH_SOURCE[0]}
	case $self in
	./*) readlink -f "$self" ;;
	/*)  echo "$self" ;;
	*)   readlink -f "$(command -v "$self")" ;;
	esac
}

self.src() {
	local path

	path=$(self.path)
	if .interactive; then
		echo "$path"
	else
		echo "builtin source '$path'"
	fi
}

self.version() {
	echo "${VERSION:-}"
}
