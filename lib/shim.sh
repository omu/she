# shim - Shims

.calling() {
	local message="${1?${FUNCNAME[0]}: missing argument}"; shift

	.say "--> $message"

	"$@"
}

.getting() {
	local message="${1?${FUNCNAME[0]}: missing argument}"; shift

	.say "... $message"

	"$@"
}

.notok() {
	.say "NOTOK $*"
}

.ok() {
	.say "OK    $*"
}

.running() {
	local message="${1?${FUNCNAME[0]}: missing argument}"; shift

	.say "... $message"

	"$@"
}
