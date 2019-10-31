# self.sh - Functions related to program itself

# Print self
self() {
	local path

	path=$(self.path)
	if .interactive; then
		echo "$path"
	else
		echo "builtin source '$path'"
	fi
}

# Install self
self.install() {
	# shellcheck disable=2192,2128
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

# Print self name
self.name() {
	local -A _; flag.parse

	# shellcheck disable=2128
	echo "$PROGNAME"
}

# Print self path
# shellcheck disable=2120
self.path() {
	local -A _; flag.parse

	local self

	self=${BASH_SOURCE[0]}
	case $self in
	./*) readlink -f "$self" ;;
	/*)  echo "$self" ;;
	*)   readlink -f "$(command -v "$self")" ;;
	esac
}

# Print self version
self.version() {
	local -A _; flag.parse

	echo 0.0
}
