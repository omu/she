# debug - Debug functions

.dbg() {
	[[ $# -gt 0 ]] || return 0

	# shellcheck disable=2178,2155
	local -n dbg_=$1

	echo "${!dbg_}"

	local key
	for key in "${!dbg_[@]}"; do
		printf '  %-16s  %s\n' "${key}" "${dbg_[$key]}"
	done | sort

	echo
}

.stacktrace() {
	local -i i=1

	while [[ -n ${BASH_SOURCE[$i]:-} ]]; do
		echo "${BASH_SOURCE[$i]}":"${BASH_LINENO[$((i-1))]}":"${FUNCNAME[$i]}"\(\)
		i=$((i + 1))
	done | grep -v "^${BASH_SOURCE[0]}"
}
