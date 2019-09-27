# has.sh - Predications at has form

has.stdin() {
	[[ ! -t 0 ]]
}

has.stdout() {
	[[ ! -t 1 ]]
}
