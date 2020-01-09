# defer.sh - Deferred functions

# Register files/directories to clean up at exit
.clean() {
	[[ -v _defer_initialized_ ]] || .defer

	_defer_clean_+=("$@")
}

# Trap defer setup
# shellcheck disable=2120
.defer() {
	if [[ -v _defer_initialized_ ]]; then
		return
	else
		_defer_initialized_=true

		declare -ag _defer_clean_=()

		if [[ -n $(builtin trap -p 2>/dev/null) ]]; then
			.cry 'Trap already taken.'

			return
		fi
	fi

	local -a signals=("$@")
	[[ $# -gt 0 ]] || signals=(EXIT HUP INT KILL QUIT TERM)

	local signal
	for signal in "${signals[@]}"; do
		# shellcheck disable=2064
		builtin trap "_defer_ $signal" "$signal"
	done

	# Prevent using trap
	trap() {
		.bug 'Using trap is forbidden; please use defer.* functions.'
	}

	# shellcheck disable=2139
	alias .untrap="trap - ${signals[*]}"

	_defer_() {
		local -r SIGNAL=$1 ERR=$?

		.callback defer

		if [[ -v _defer_clean_ ]] && [[ "${#_defer_clean_[@]}" -gt 0 ]]; then
			rm -rf -- "${_defer_clean_[@]}"
		fi

		builtin trap - EXIT

		if [[ $SIGNAL = INT ]] || [[ $SIGNAL = QUIT ]]; then
			builtin trap - "$SIGNAL"; kill -s "$SIGNAL" "$$"
		fi

		return "$ERR"
	}

	readonly -f _defer_
}
