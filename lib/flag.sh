# flag.sh - Flag handling

shopt -s expand_aliases

# shellcheck disable=2142
alias flag.parse='flag.parse_ "$@"; local -a __a; flag.args_ __a; set -- "${__a[@]}"; unset -v __a'

# shellcheck disable=2034
declare -gr NIL="\0"

flag.usage_() {
	if [[ -n ${_[.help]:-} ]]; then
		# shellcheck disable=2128
		.say "Usage: ${PROGNAME[*]} ${_[.help]}"
	else
		# shellcheck disable=2128
		.say "Usage: ${PROGNAME[*]}"
	fi

	[[ $# -gt 0 ]] || return 0

	exit "$1"
}

# shellcheck disable=2034
flag.parse_() {
	if .contains -help "$@"; then
		flag.usage_ 0
	fi

	local -A flag_result_

	local -i argc=0
	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
			if [[ $key =~ ^-.+$ ]] && [[ ! -v _[$key] ]]; then
				.die "Unrecognized flag: $key"
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

	flag.load flag_result_

	flag._validate_ $argc
}

flag.load() {
	local -n _load_src_=${1?${FUNCNAME[0]}: missing argument}; shift

	local key
	for key in "${!_load_src_[@]}"; do
		# shellcheck disable=2034
		_[$key]=${_load_src_[$key]}
	done
}

flag.values() {
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

flag.args_() {
	flag.values '^[1-9][0-9]*$' "$@"
}

flag.env_() {
	flag.values '^[[:alpha:]_][[:alnum:]_]*$' "$@"
}

flag.true() {
	.bool "${_[$1]:-}"
}

flag.false() {
	! flag.true "$@"
}

flag.nil() {
	[[ ${_[$1]:-} = "$NIL" ]]
}

flag._nils_() {
	local -a required=()

	local key
	for key in "${!_[@]}"; do
		if flag.nil "$key"; then
			required+=("$key")
		fi
	done

	[[ ${#required[@]} -eq 0 ]] || .die "Missing values for: ${required[*]}"
}

flag._args_() {
	local n=${1?${FUNCNAME[0]}: missing argument}; shift

	local argc=${_[.argc]:-0}

	[[ $argc != '-' ]] || return 0

	local lo hi

	if [[ $argc =~ ^[0-9]+$ ]]; then
		lo=$argc; hi=$argc
	elif [[ $argc =~ ^[0-9]*-[0-9]*$ ]]; then
		IFS=- read -r lo hi <<<"$argc"
	else
		.bug "Incorrect range: $argc"
	fi

	if   [[ -n ${lo:-} ]] && [[ $n -lt $lo ]]; then
		.die- 'Too few arguments'
	elif [[ -n ${hi:-} ]] && [[ $n -gt $hi ]]; then
		.die- 'Too many arguments'
	else
		return 0
	fi

	flag.usage_ 1
}

flag._validate_() {
	flag._args_ "$@"
	flag._nils_
}
