# flag.sh - Flag handling

shopt -s expand_aliases

# shellcheck disable=2142
alias flag.parse='flag.parse_ "$@"; local -a __a; flag.args_ __a; set -- "${__a[@]}"; unset -v __a'

flag.usage_() {
	if [[ -n ${_[.help]:-} ]]; then
		# shellcheck disable=2128
		say "Usage: ${PROGNAME[*]} ${_[.help]}"
	else
		# shellcheck disable=2128
		say "Usage: ${PROGNAME[*]}"
	fi

	[[ $# -gt 0 ]] || return 0

	exit "$1"
}

# shellcheck disable=2034
flag.parse_() {
	if contains -help "$@"; then
		flag.usage_ 0
	fi

	local -A flag_result_

	local -i argc=0
	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
			if [[ $key =~ ^-.+$ ]] && [[ ! -v _[$key] ]]; then
				die "Unrecognized flag: $key"
			fi
		elif [[ $1 == '--' ]]; then
			shift
			break
		else
			key=$((++argc)); value=$1
		fi

		flag_result_["$key"]=${value:-${_["$key"]:-}}

		shift
	done

	flag._post_ $argc

	_.load flag_result_
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

flag._post_() {
	local n=${1?missing argument}

	local argc=${_[.argc]:-0}

	[[ $argc != '-' ]] || return 0

	local lo hi

	if [[ $argc =~ ^[0-9]+$ ]]; then
		lo=$argc; hi=$argc
	elif [[ $argc =~ ^[0-9]*-[0-9]*$ ]]; then
		IFS=- read -r lo hi <<<"$argc"
	else
		bug "Incorrect range: $argc"
	fi

	if   [[ -n ${lo:-} ]] && [[ $n -lt $lo ]]; then
		die- 'Too few arguments'
	elif [[ -n ${hi:-} ]] && [[ $n -gt $hi ]]; then
		die- 'Too many arguments'
	else
		return 0
	fi

	flag.usage_ 1
}
