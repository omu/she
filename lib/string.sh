# string.sh - String manipulation

string.has_prefix_deleted() {
	local -n string_has_prefix_deleted_=${1?${FUNCNAME[0]}: missing argument}; shift
	local    prefix=${1?${FUNCNAME[0]}: missing argument};                     shift

	if [[ $string_has_prefix_deleted_ =~ ^$prefix ]]; then
		string_has_prefix_deleted_=${string_has_prefix_deleted_#$prefix}

		return 0
	fi

	return 1
}

string.delete_prefix() {
	string.has_prefix_deleted "$@" || :
}

string.has_suffix_deleted() {
	local -n string_has_suffix_deleted_=${1?${FUNCNAME[0]}: missing argument}; shift
	local    suffix=${1?${FUNCNAME[0]}: missing argument};                     shift

	if [[ $string_has_suffix_deleted_ =~ $suffix$ ]]; then
		string_has_suffix_deleted_=${string_has_suffix_deleted_%$suffix}

		return 0
	fi

	return 1
}

string.delete_suffix() {
	string.has_suffix_deleted "$@" || :
}
