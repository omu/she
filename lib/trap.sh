# trap.sh - Trap setup

declare -ag _at_exit_funcs_=()

declare -ag _at_exit_files_=()

# shellcheck disable=2120
trap._init() {
	local -a signals=(EXIT HUP INT QUIT TERM)

	[[ $# -eq 0 ]] || signals=("$@")

	# shellcheck disable=2154,2218
	builtin trap _exit_ "${signals[@]}"

	at_exit _at_exit_cleanup_
}

# Prevent using trap
trap() {
	bug 'Using trap is forbidden; please use at_exit to register hooks.'
}

# Register hooks at exit
at_exit() {
	local arg

	for arg; do
		[[ $(type -t "$arg" || true) == function ]] || bug "Not a function: $arg"
	done

	_at_exit_funcs_=("$@" "${_at_exit_funcs_[@]}")
}

# Register files/directories to clean up at exit
at_exit_files() {
	_at_exit_files_+=("$@")
}

# trap - Private functions

_exit_() {
	local err=$?

	local func
	for func in "${_at_exit_funcs_[@]}"; do
		"$func" || cry "Exit hook failed: $func"
	done

	return "$err"
}

_at_exit_cleanup_() {
	[[ ${#_at_exit_files_[@]} -gt 0 ]] || return 0

	rm -rf -- "${_at_exit_files_[@]}"
}

trap._init
