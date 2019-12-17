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

	file.run "${x[target]}" "$@"
}
