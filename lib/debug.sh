# Debug functions

# Dump an array variable
debug.dump() {
	while [[ $# -gt 0 ]]; do
		# shellcheck disable=2178,2155
		local -n variable_=$(public "$1")

		echo "${!variable_}"

		local key_
		for key_ in "${!variable_[@]}"; do
			printf '  %-16s  %s\n' "${key_}" "${variable_[$key_]}"
		done | sort
		echo

		shift
	done
}
