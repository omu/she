# array.sh - Array functions

# Join array with the given separator
array.join() {
	local IFS=$1
	shift

	echo "$*"
}
# Duplicate array
array.dup() {
	local -n array_dup_lhs_=$1 array_dup_rhs_=$2

	local key
	for key in "${!array_dup_rhs_[@]}"; do
		# shellcheck disable=2034
		array_dup_lhs_[$key]=${array_dup_rhs_[$key]}
	done
}
