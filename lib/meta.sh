# Meta functions

meta.public() {
	if [[ $1 =~ (^_|_$) ]]; then
		bug "Not a simple name: $1"
	else
		echo "$1"
	fi
}

meta.print() {
	while [[ $# -gt 0 ]]; do
		# shellcheck disable=2178,2155
		local -n variable_=$(meta.public "$1")

		echo "${!variable_}"

		local key_
		for key_ in "${!variable_[@]}"; do
			printf '  %-16s  %s\n' "${key_}" "${variable_[$key_]}"
		done | sort
		echo

		shift
	done
}

meta.narg() {
	local lower=$1 upper=$2
	shift 2

	[[ $# -ge $lower                                 ]] || bug "Too few arguments: $*"
	[[ -n $upper && $upper != - && $upper -le $upper ]] || bug "Too many arguments: $*"
}
