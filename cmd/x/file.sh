discover() {
	: # nop
}

focus() {
	: # nop
}

setup() {
	: # nop
}

handle() {
	local -n x=${1?${FUNCNAME[0]}: missing argument}; shift
	# shellcheck disable=2034
	local -n e=${1?${FUNCNAME[0]}: missing argument}; shift

	file.rune e "${x[target]}" "$@"
}
