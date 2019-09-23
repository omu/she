# self.sh - Functions related to program itself

# self.version: Print self version
self.version() {
	echo 0.0
}

# self.name: Print self name
self.name() {
	echo she
}

# self.path: Print self path
self.path() {
	local self

	self=${BASH_SOURCE[0]}
	case $self in
	./*) readlink -f "$self" ;;
	/*)  echo "$self" ;;
	*)   readlink -f "$(command -v "$self")" ;;
	esac
}

self.usage() {
	local message

	for message;  do
		echo >&2 "$message"
	done

	echo >&2 "Usage: $(self.path) CMD [ARGS]..."
	exit 1
}
