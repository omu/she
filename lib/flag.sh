# flag.sh - Flag handling

shopt -s expand_aliases

# shellcheck disable=2142
alias flag.parse='flag.parse_ "$@"; set -- $(flag.args_)'

flag.parse_() {
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

	flag._post flag_parse_ "$i"
}

flag.args_() {
	_.select '^[1-9][0-9]*$' "$@"
}

flag.env_() {
	_.select '^[[:alpha:]_][[:alnum:]_]*$' "$@"
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

flag._post() {
	local -n flag_post_=${1?missing argument}; shift
	local    i=${1?missing argument};          shift

	local argc=${flag_post_[.argc]:-}; [[ -n $argc ]] || return 0

	local lo hi

	if [[ $argc =~ ^[0*9]+$ ]]; then
		lo=$argc; hi=$argc
	elif [[ $argc =~ ^[0-9]*-[0-9]*$ ]]; then
		IFS=- read -r lo hi <<<"$argc"
	else
		bug "Incorrect range: $argc"
	fi

	local -a messages

	if   [[ -n ${lo:-} ]] && [[ $i -lt $lo ]]; then
		messages+=('Too few arguments')
	elif [[ -n ${hi:-} ]] && [[ $i -gt $hi ]]; then
		messages+=('Too many arguments')
	else
		return 0
	fi

	if [[ -n ${flag_post_[.help]:-} ]]; then
		messages+=("" "Usage: ${COMMAND:-} ${flag_post_[.help]}")
	else
		messages+=("" "Usage: ${COMMAND:-}")
	fi

	die "${messages[@]}"
}
