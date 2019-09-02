# Trap setup

declare -ag _at_exit_callbacks_=()

declare -ag _at_exit_cleandirs_=()

# Prevent using trap
trap() {
	bug "Using trap is forbidden; please use at_exit".
}

at_exit() {
	declare -fx "${_at_exit_callbacks_[@]}"

	_at_exit_callbacks_=("$@" "${_at_exit_callbacks_[@]}")
}

_exit_() {
	local err=$?

	local callback
	for callback in "${_at_exit_callbacks_[@]}"; do
		"$callback" || warn "Exit callback: $callback"
	done

	return "$err"
}

# shellcheck disable=2154
builtin trap '_exit_ $?' EXIT HUP INT QUIT TERM

_at_exit_cleanup_() {
	[[ ${#_at_exit_cleandirs_[@]} -gt 0 ]] || return 0

	rm -rf -- "${_at_exit_cleandirs_[@]}"
}

at_exit _at_exit_cleanup_
