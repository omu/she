# debug.sh - Debug functions

debug.trace() {
	local -i i=1

	while [[ -n ${BASH_SOURCE[$i]:-} ]]; do
		echo "${BASH_SOURCE[$i]}":"${BASH_LINENO[$((i-1))]}":"${FUNCNAME[$i]}"\(\)
		i=$((i + 1))
	done | grep -v "^${BASH_SOURCE[0]}"
}
