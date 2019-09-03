# Trap setup

declare -ag _at_exit_hooks_=()

declare -ag _at_exit_dirs_=()

# Register hooks at exit
at_exit() {
	local arg
	for arg; do
		[[ $(type -t "$arg" || true) == function ]] || bug "Not a function: $arg"
	done

	_at_exit_hooks_=("$@" "${_at_exit_hooks_[@]}")
}

# Register directories to clean up at exit
at_exit_dirs() {
	_at_exit_dirs_+=("$@")
}

_exit_() {
	local err=$?

	local hook
	for hook in "${_at_exit_hooks_[@]}"; do
		"$hook" || warn "Exit hook failed: $hook"
	done

	return "$err"
}

# shellcheck disable=2154,2218
builtin trap '_exit_ $?' EXIT HUP INT QUIT TERM

# Prevent using trap
trap() {
	bug 'Using trap is forbidden; please use at_exit to register hooks.'
}

_at_exit_cleanup_() {
	[[ ${#_at_exit_dirs_[@]} -gt 0 ]] || return 0

	rm -rf -- "${_at_exit_dirs_[@]}"
}

at_exit _at_exit_cleanup_
