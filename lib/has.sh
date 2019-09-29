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

# has.file.shebang: Detect shebang
has.file.shebang() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	head -n 1 "$file" | grep -q '^#!'
}
