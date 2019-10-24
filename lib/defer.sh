# defer.sh - Deferred functions

# shellcheck disable=2120
defer.init() {
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

	# defer - Private functions

	_defer_() {
		local -r SIG=$1 ERR=$?

		local -a _defer_funcs_

		mapfile -t _defer_funcs_ < <(
			shopt -s extdebug

			declare -F | grep 'declare -f defer[.]' | awk '{ print $3 }' |
			while read -r func; do declare -F "$func"; done |
			sort -t' ' -k2 -n | awk '
				$1 !~ /defer[.]early|defer[.]late/ {
					print $1
				}
			'
		)

		! .callable defer.early || defer.early

		local func
		for func in "${_defer_funcs_[@]}"; do
			"$func" || .cry "Deferred function failed: $func"
		done

		if [[ -v _defer_clean_ ]] && [[ "${#_defer_clean_[@]}" -gt 0 ]]; then
			rm -rf -- "${_defer_clean_[@]}"
		fi

		! .callable defer.late || defer.late

		builtin trap - EXIT

		if [[ $SIG = INT ]] || [[ $SIG = QUIT ]]; then
			builtin trap - "$SIG"; kill -s "$SIG" "$$"
		fi

		return "$ERR"
	}

	readonly -f _defer_
}

# Register files/directories to clean up at exit
.clean() {
	[[ -v _defer_initialized_ ]] || defer.init

	_defer_clean_+=("$@")
}
