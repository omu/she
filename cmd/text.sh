# cmd/text - Text manipulation commands

# Append stdin content to the target file
text:fix() {
	local -A _=(
		[.help]='FILE [MARK]'
		[.argc]=1-
	)

	flag.parse

	text.fix "$@"
}

# Remove appended content
text:unfix() {
	local -A _=(
		[.help]='FILE [MARK]'
		[.argc]=1-
	)

	flag.parse

	text.unfix "$@"
}
