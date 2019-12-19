discover() {
	: # nop
}

# shellcheck disable=2128
focus() {
	local -n x=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ -n ${x[center]:-} ]]; then
		.must -- cd "${x[center]}"

		return 0
	fi

	file.upcd "${x[target]}" .META .git
}

setup() {
	: # nop
}

handle() {
	local -n x=${1?${FUNCNAME[0]}: missing argument}; shift
	# shellcheck disable=2034
	local -n e=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ $# -eq 0 ]]; then
		discover

		return 0
	fi

	local cmd=$1
	shift

	local found

	found=$(file.match "$cmd" './bin/%s' './sbin/%s' './script/%s' './scripts/%s.*') || .die "No runnable found"

	filetype.runnable "$found" || .die "Not a runnable: $found"

	file.rune e "$found" "$@"
}
