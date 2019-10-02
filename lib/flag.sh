# flag.sh - Flag handling

flag.parse() {
	local -A flag_parse_

	_.reset flag_parse_

	local -i i=0

	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
			if [[ $key =~ ^-.+$ ]] && [[ ! -v flag_parse_[$key] ]]; then
				die "Unrecognized flag: $key"
			fi
		elif [[ $1 == '--' ]]; then
			shift
			break
		else
			key=$((++i)); value=$1
		fi

		_["$key"]=${value:-${_["$key"]:-}}

		shift
	done

	if [[ -v flag_parse_[.argc] ]] && [[ $i -ne ${flag_parse_[.argc]} ]]; then
		local -a messages

		if   [[ $i -lt ${flag_parse_[.argc]} ]]; then
			messages+=('Too few arguments')
		elif [[ $i -gt ${flag_parse_[.argc]} ]]; then
			message+=('Too many arguments')
		fi

		[[ ! -v flag_parse_[.help] ]] || messages+=("${flag_parse_[.help]}")

		die "${messages[@]}"
	fi
}

flag.env() {
	_.select '^[[:alpha:]_][[:alnum:]_]*$' "$@"
}

flag.args() {
	_.select '^[1-9][0-9]+$' "$@"
}

flag.true() {
	bool "${_[-$1]:-}"
}

flag.false() {
	! flag.true "$@"
}

flag.dump() {
	_.dump
}
