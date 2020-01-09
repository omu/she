# main - Application

.usage() {
	# shellcheck disable=2128
	.say "Usage: $PROGNAME COMMAND... [-FLAG=VALUE...] [ARGS]"
	.say ""
	.say "Commands:"

	local cmd

	# shellcheck disable=2154
	for cmd in "${!_command[@]}"; do
		local fun=${_command[$cmd]}

		printf "\\t%-24s  %s\n" "$cmd" "${_help[$fun]:-}"
	done | sort >&2
}

# shellcheck disable=2154
.dispatch() {
	local orig="${*}"

	if [[ $# -eq 0 ]]; then
		.usage

		.die 'Command required'
	fi

	local help=

	if [[ $1 = help ]]; then
		help=true

		shift

		if [[ $# -eq 0 ]]; then
			.usage

			.die 'Help topic required'
		fi
	fi

	local -a args=("$@") try

	local cmd
	while [[ $# -gt 0 ]]; do
		try+=("$1")
		shift

		if [[ -n ${_command[${try[*]}]:-} ]]; then
			cmd=${try[*]}
			args=("$@")
		fi
	done

	[[ -n ${cmd:-} ]] || .die "Wrong or missing command: $orig"

	local fun=${_command["$cmd"]}

	CMDNAMES+=("$cmd")

	if [[ -n ${help:-} ]]; then
		.say "${_help[$fun]:-}" ""

		"$fun" -help
	else
		"$fun" "${args[@]}"
	fi
}

.redirect() {
	local -a args=("$@") try

	local cmd
	while [[ $# -gt 0 ]]; do
		try+=("$1")
		shift

		if [[ -n ${_command[${try[*]}]:-} ]]; then
			cmd=${try[*]}
			args=("$@")
		fi
	done

	[[ -n ${cmd:-} ]] || .die "No command found: $orig"

	local fun=${_command["$cmd"]}

	unset 'CMDNAMES[${#CMDNAMES[@]}-1]'
	CMDNAMES+=("$cmd")

	"$fun" "${args[@]}"
}
