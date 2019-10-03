# flag.sh - Flag handling

shopt -s expand_aliases

# shellcheck disable=2142
alias flag.parse='flag.parse_ "$@"; local -a __a; flag.args_ __a; set -- "${__a[@]}"; unset -v __a'

flag.parse_() {
	local -A flag_parse_

	_.reset flag_parse_

	local -i i=0

	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 = -help ]]; then
			flag.usage_ flag_parse_
			exit 0
		elif [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
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

flag.usage_() {
	local -n flag_usage_=${1:-_}

	say "Usage: ${PROGNAME[*]} ${flag_usage_[.help]:-}"
}

flag.args_() {
	_.values '^[1-9][0-9]*$' "$@"
}

flag.env_() {
	_.values '^[[:alpha:]_][[:alnum:]_]*$' "$@"
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

	local argc=${flag_post_[.argc]:-0}

	[[ $argc != '-' ]] || return 0

	local lo hi

	if [[ $argc =~ ^[0-9]+$ ]]; then
		lo=$argc; hi=$argc
	elif [[ $argc =~ ^[0-9]*-[0-9]*$ ]]; then
		IFS=- read -r lo hi <<<"$argc"
	else
		bug "Incorrect range: $argc"
	fi

	if   [[ -n ${lo:-} ]] && [[ $i -lt $lo ]]; then
		die- 'Too few arguments'
	elif [[ -n ${hi:-} ]] && [[ $i -gt $hi ]]; then
		die- 'Too many arguments'
	else
		return 0
	fi

	die-
	flag.usage_ flag_post_
	exit 1
}

flag._help() {
	local -n flag_help_=${1?missing argument}; shift

	if [[ -n ${flag_help_[.help]:-} ]]; then
		# shellcheck disable=2128
		echo "Usage: ${PROGNAME[*]} ${flag_help_[.help]}"
	else
		# shellcheck disable=2128
		echo "Usage: ${PROGNAME[*]}"
	fi
}
