# array.sh - Array functions

# Join array with the given separator
array.join() {
	local IFS=${1?${FUNCNAME[0]}: missing argument}; shift

	echo "$*"
}
# Duplicate array
array.dup() {
	local -n array_dup_lhs_=${1?${FUNCNAME[0]}: missing argument}; shift
	local -n array_dup_rhs_=${1?${FUNCNAME[0]}: missing argument}; shift

	local key
	for key in "${!array_dup_rhs_[@]}"; do
		# shellcheck disable=2034
		array_dup_lhs_[$key]=${array_dup_rhs_[$key]}
	done
}

# The element included in the given array
array.included() {
	local -n array_included_=${1?${FUNCNAME[0]}: missing argument}; shift
	local    element=${1?${FUNCNAME[0]}: missing argument};         shift

	included "$element" "${array_included_[@]}"
}
