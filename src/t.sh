t() {
	local cmd

	[[ $# -gt 0 ]] || .die 'Test command required'

	cmd=$1
	shift

	[[ $cmd =~ ^[a-z][a-z0-9-]+$ ]] || .die "Invalid command name: $cmd"

	if .callable t."$cmd"; then
		t."$cmd" "$@"
	else
		tap "$@"
	fi
}

[[ $# -eq 0 ]] || .load "$@"
