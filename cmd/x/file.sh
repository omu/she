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
	local target=${1?${FUNCNAME[0]}: missing argument}; shift

	file.run "${X[target]}" "$@"
}
