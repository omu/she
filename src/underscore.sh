#!/usr/bin/env bash

#:lib/_.sh

.prelude

#:lib/flag.sh

#:lib/ui.sh

#:lib/must.sh

#:lib/self.sh

#:lib/string.sh

#:lib/array.sh

#:lib/path.sh

#:lib/trap.sh

#:lib/temp.sh

#:lib/os.sh

#:lib/url.sh

#:lib/http.sh

#:lib/file.sh

#:lib/bin.sh

#:lib/git.sh

#:lib/src.sh

#:lib/deb.sh

#:lib/text.sh

#:lib/filetype.sh

#:lib/zip.sh

#/help/

declare -Ag _command=(
	['bin install']='bin.install'
	['bin use']='bin.use'
	['bug']='ui.bug'
	['cry']='ui.cry'
	['deb install']='deb.install'
	['deb missings']='deb.missings'
	['deb repository']='deb.repository'
	['deb uninstall']='deb.uninstall'
	['deb update']='deb.update'
	['deb using']='deb.using'
	['die']='ui.die'
	['enter']='src.enter'
	['file install']='file.install'
	['filetype is']='filetype.is'
	['filetype mime']='filetype.mime'
	['hey']='ui.hey'
	['http get']='http.get'
	['http is']='http.is'
	['os codename']='os.codename'
	['os dist']='os.dist'
	['os is']='os.is'
	['os virtual']='os.virtual'
	['run']='src.run'
	['say']='ui.say'
	['self install']='self.install'
	['self name']='self.name'
	['self path']='self.path'
	['self version']='self.version'
	['src install']='src.install'
	['src use']='src.use'
	['temp inside']='temp.inside'
	['text fix']='text.fix'
	['text unfix']='text.unfix'
	['unzip']='zip.unpack'
	['url is']='url.is'
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

	.init

	if [[ -n ${help:-} ]]; then
		.say "${_help[$fun]}" ""
		"$fun" -help
	else
		"$fun" "$@"
	fi
}

.source() {
	cat "$(self.path)"
}

.builtin() {
	echo "UNDERSCORE=$(self.path)"
	echo
	sed 's/^\t//' <<'EOF'
	#:lib/_.sh: .prelude
	.prelude

	#:src/underscore/builtin.sh
EOF
}

.main() {
	# shellcheck disable=2128
	case $PROGNAME in
	underscore|i)
		.execute "$@"
		;;
	_)
		.builtin "$@"
		;;
	she)
		.source "$@"
		;;
	esac
}

[[ "${BASH_SOURCE[0]}" != "$0" ]] || .main "$@"

