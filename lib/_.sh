# _.sh - Default result variable

declare -gA _=()

_.read() {
	local -i i=1

	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
		elif [[ $1 == '--' ]]; then
			shift
			break
		else
			key=$((i++)); value=$1
		fi

		_["$key"]=${value:-${_["$key"]:-}}

		shift
	done
}

_.values() {
	local pattern=${1?${FUNCNAME[0]}: missing argument}; shift

	local -a keys

	mapfile -t keys < <(
		for key in "${!_[@]}"; do
			[[ $key =~ $pattern ]] || continue

			echo "$key"
		done | sort -u
	)

	local key

	if [[ $# -gt 0 ]]; then
		local -n _values_=$1

		for key in "${keys[@]}"; do
			_values_+=("${_[$key]}")
		done

		_values_=("${_values_[@]}")
	else
		for key in "${keys[@]}"; do
			echo "${_[$key]}"
		done
	fi
}

_.dump() {
	hmm _
}
