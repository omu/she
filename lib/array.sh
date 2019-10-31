# array.sh - Array functions

# Array contains the given element
array.contains() {
	local -n array_contains_=${1?${FUNCNAME[0]}: missing argument}; shift
	local    element=${1?${FUNCNAME[0]}: missing argument};         shift

	.contains "$element" "${array_contains_[@]}"
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

# Join array with the given separator
array.join() {
	local IFS=${1?${FUNCNAME[0]}: missing argument}; shift

	echo "$*"
}
