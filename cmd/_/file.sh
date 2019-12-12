# cmd/file - File operations

# Change owner, group and mode
file:chmog() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='[MODE]:[OWNER]:[GROUP] FILE|DIR'
		[.argc]=2
	)

	flag.parse

	local mog=$1 dst=$2

	file.chmog "$mog" "$dst"
}

# Run program
file:run() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='FILE|DIR'
		[.argc]=1
	)

	flag.parse

	file:run_ "$@"
	# TODO
}
