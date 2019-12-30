# cmd/_ - Essential commands

# Return if program available
:available() {
	local -A _=(
		[.help]='<program>'
		[.argc]=1
	)

	flag.parse

	.available "$@"
}

# Return if first argument found in remaining arguments
:contains() {
	local -A _=(
		[.help]='<needle> <haystack>'
		[.argc]=2-
	)

	flag.parse

	.contains "$@"
}

# Return if any of the files expired
:expired() {
	local -A _=(
		[-ttl]=3

		[.help]='[-ttl=<minutes>] <file>...'
		[.argc]=1-
	)

	flag.parse

	.expired "${_[-ttl]}" "$@"
}

# Ensure the given command succeeds
:must() {
	local -A _=(
		[.help]='<message> (<arg>... | -- <arg>...)'
		[.argc]=2-
		[.dash]=true
	)

	flag.parse

	.must "$@"
}

# Ignore error if the given command fails
:should() {
	local -A _=(
		[.help]='<message> (<arg>... | -- <arg>...)'
		[.argc]=2-
		[.dash]=true
	)

	flag.parse

	.should "$@"
}

# Run a local or remote file with optional environment
:run() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='(<file> |<url>) [<arg>...]'
		[.argc]=1-
	)

	flag.parse

	# shellcheck disable=2034
	local -a env=(); flag.env env

	local url=$1
	shift

	local file

	if url.is "$url" schemed; then
		local -A src

		src.get "$url" src

		file=${src[cache]}

		[[ -z ${src[inpath]:-} ]] || file=${src[cache]}/${src[inpath]}

		[[ -e $file ]] || .die "No file found: $url"
		[[ -f $file ]] || .die "Not a file: $url"
	else
		file=$url

		.must "No such file: $file" [[ -f "$file" ]]
	fi

	file.rune env "$file" "$@"
}
