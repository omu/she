# self.sh - Functions related to program itself

# self.version: Print self version
self.version() {
	local -A _=([.argc]=0); flag.parse

	echo 0.0
}

# self.name: Print self name
self.name() {
	local -A _=([.argc]=0); flag.parse

	echo "$PROGNAME"
}

# self.path: Print self path
# shellcheck disable=2120
self.path() {
	local -A _=([.argc]=0); flag.parse

	local self

	self=${BASH_SOURCE[0]}
	case $self in
	./*) readlink -f "$self" ;;
	/*)  echo "$self" ;;
	*)   readlink -f "$(command -v "$self")" ;;
	esac
}

# self.install: Install self
self.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefix]="$_USR"/bin
		[-name]=$PROGNAME

		[.help]=
		[.argc]=0
	)

	flag.parse

	_[1]=$(self.path)

	bin.install_
}

self.usage() {
	local -A _=([.argc]=0); flag.parse

	local message

	for message;  do
		echo >&2 "$message"
	done

	echo >&2 "Usage: $(self.path) CMD [ARGS]..."
	exit 1
}
