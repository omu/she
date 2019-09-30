# has.sh - Predications at has form

has.command() {
	command -v "$1" &>/dev/null
}

has.stdin() {
	[[ ! -t 0 ]]
}

has.stdout() {
	[[ ! -t 1 ]]
}
