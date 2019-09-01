# Print on stderr
warn() {
	echo >&2 "$*"
}

# Warn and fail
abort() {
	warn "$@"
	exit 1
}

[ -n "${BASH_VERSION:-}" ] || abort 'Bash required.'
