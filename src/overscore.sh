#!/usr/bin/env bash

#:lib/_.sh

.prelude

#:lib/flag.sh

#:lib/must.sh

#/help/

declare -Ag _command=(
	['isnt']='test.isnt'
	['is']='test.is'
	['notok']='test.notok'
	['ok']='test.ok'
)

.usage() {
	local cmd

	# shellcheck disable=2128
	.say "$PROGNAME COMMAND... [-FLAG=VALUE...] [ARGS]"
	.say "Commands:"

	# shellcheck disable=2154
	for cmd in "${!_command[@]}"; do
		local fun=${_command[$cmd]}

		printf "\\t%-24s  %s\n" "$cmd" "${_help[$fun]}"
	done | sort >&2
}

.execute() {
	trap.setup

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

	local -a args=("$@")

	local fun
	local try cmd

	while [[ $# -gt 0 ]]; do
		try+=("$1")
		shift

		if [[ -n ${_command[${try[*]}]:-} ]]; then
			cmd=${try[*]}; fun=${_command[$cmd]}
			break
		fi
	done

	if [[ -z ${fun:-} ]]; then
		.die "No command found: ${args[*]}"
	fi

	readonly PROGNAME+=("$cmd")

	if [[ -n ${help:-} ]]; then
		.say "${_help[$fun]}" ""
		"$fun" -help
	else
		"$fun" "$@"
	fi
}

.builtin() {
	sed 's/^\t//' <<'EOF'
	#:lib/_.sh: .prelude .say .cry .die .bug .contains .available .callable

	.prelude

	#:lib/assert.sh
EOF
	echo
	echo "OVERSCORE=$(self.path)"
	echo
	sed 's/^\t//' <<'EOF'
	#:src/overscore/builtin.sh
EOF
}

.main() {
	# shellcheck disable=2128
	case $PROGNAME in
	overscore)
		.execute "$@"
		;;
	t)
		.builtin "$@"
		;;
	esac
}

[[ "${BASH_SOURCE[0]}" != "$0" ]] || .main "$@"

