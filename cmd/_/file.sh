# cmd/file - File operations

# Change owner, group and mode
file:chmog() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='[<mode>]:[<owner>]:[<group>] (<file> | <dir>)'
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
		[.help]='(<file> | <dir>)'
		[.argc]=1-
	)

	flag.parse

	local file=$1
	shift

	# shellcheck disable=2034
	local -a env=(); flag.env env

	file.rune env "$file" "$@"
}
