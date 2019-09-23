# meta.sh - Meta functions

# Dump an array variable
meta.dump() {
	while [[ $# -gt 0 ]]; do
		# shellcheck disable=2178,2155
		local -n meta_dump_=$1

		echo "${!meta_dump_}"

		local key
		for key in "${!meta_dump_[@]}"; do
			printf '  %-16s  %s\n' "${key}" "${meta_dump_[$key]}"
		done | sort
		echo

		shift
	done
}

_.dump() {
	meta.dump _
}

meta.apply() {
	local func=${1?missing argument: func}
	shift

	local -A meta_apply_

	while [[ $# -gt 0 ]]; do
		local -n meta_apply_overwrite_=$1

		local key
		for key in "${!meta_apply_overwrite_[@]}"; do
			# shellcheck disable=2034
			meta_apply_[$key]=${meta_apply_overwrite_[$key]}
		done

		shift
	done

	"$func" meta_apply_
}

meta.bool() {
	local value=${1:-}

	case $value in
	true|on|yes|1)
		return 0
		;;
	false|off|no|0|"")
		return 1
		;;
	*)
		bug "Invalid boolean: $value"
	esac
}
