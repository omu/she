# array - Array functions

# array.join: Join array with the given separator
array.join() {
	local IFS=$1
	shift

	echo "$*"
}
