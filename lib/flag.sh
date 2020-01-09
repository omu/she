# flag.sh - Flag handling

flag.args() {
	local -a keys

	mapfile -t keys < <(
		for key in "${!_[@]}"; do
			[[ $key =~ ^[1-9][0-9]*$ ]] || continue

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

flag.env() {
	local -a keys

	mapfile -t keys < <(
		for key in "${!_[@]}"; do
			[[ $key =~ ^[[:alpha:]_][[:alnum:]_]*$ ]] || continue

			echo "$key"
		done | sort -u
	)

	local key

	if [[ $# -gt 0 ]]; then
		# shellcheck disable=2178
		local -n _values_=$1

		for key in "${keys[@]}"; do
			_values_+=("$key='${_[$key]}'")
		done
	else
		for key in "${keys[@]}"; do
			echo "$key='${_[$key]}'"
		done
	fi
}

flag.false() {
	! flag.true "$@"
}

flag.load() {
	local -n _load_src_=${1?${FUNCNAME[0]}: missing argument}; shift

	local key
	for key in "${!_load_src_[@]}"; do
		# shellcheck disable=2034
		_[$key]=${_load_src_[$key]}
	done
}

flag.nil() {
	[[ ${_[$1]:-} = "$NIL" ]]
}

flag.parse-() {
	if .contains -help "$@"; then
		flag.usage-and-bye
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

			if [[ $key =~ ^-.+$ ]]; then
				[[ -v _[$key] ]] || .die "Unrecognized flag: $key"
			elif [[ -n ${_[.raw]:-} ]]; then
				key=$((++argc)); value=$1
			fi
		elif [[ $1 == '--' ]] && [[ -z ${_[.dash]:-} ]]; then
			shift
			break
		else
			key=$((++argc)); value=$1
		fi

		# shellcheck disable=2034
		flag_result_["$key"]=${value:-${_["$key"]:-}}

		shift
	done

	flag.load flag_result_

	flag.validate- $argc
}

flag.peek-() {
	if .contains -help "$@"; then
		flag.usage-and-bye
	fi

	local -A flag_result_

	local -i argc=0
	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
		elif [[ $1 == '--' ]] && [[ -z ${_[.dash]:-} ]]; then
			shift
			break
		else
			key=$((++argc)); value=$1
		fi

		# shellcheck disable=2034
		flag_result_["$key"]=${value:-${_["$key"]:-}}

		shift
	done

	flag.load flag_result_

	flag.validate- $argc
}

flag.true() {
	.bool "${_[$1]:-}"
}

flag.usage() {
	local name="$PROGNAME ${CMDNAMES[*]}"

	if [[ -n ${_[.help]:-} ]]; then
		# shellcheck disable=2128
		.say "Usage: $name ${_[.help]}"
	else
		# shellcheck disable=2128
		.say "Usage: $name"
	fi
}

flag.usage-and-die() {
	flag.usage

	.die "$@"
}

# shellcheck disable=2120
flag.usage-and-bye() {
	flag.usage

	.bye "$@"
}

# flag - Private functions

flag.args-() {
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

	local message
	if   [[ -n ${lo:-} ]] && [[ $n -lt $lo ]]; then
		message='Too few arguments'
	elif [[ -n ${hi:-} ]] && [[ $n -gt $hi ]]; then
		message='Too many arguments'
	else
		return 0
	fi

	flag.usage-and-die "$message"
}

flag.nils-() {
	local -a required=()

	local key
	for key in "${!_[@]}"; do
		if flag.nil "$key"; then
			required+=("$key")
		fi
	done

	[[ ${#required[@]} -eq 0 ]] || .die "Value missing for: ${required[*]}"
}

flag.validate-() {
	flag.args- "$@"
	flag.nils-
}

# flag - Private functions

.bool() {
	local value=${1:-}

	value=${value,,}

	case $value in
	true|t|1|on|yes|y)
		return 0
		;;
	false|f|0|off|no|n|"")
		return 1
		;;
	*)
		.bug "Invalid boolean: $value"
	esac
}

# flag - Init

flag.init-() {
	shopt -s expand_aliases

	# shellcheck disable=2142
	alias flag.parse='flag.parse- "$@"; local -a __argv__ ARGV=("$@"); flag.args __argv__; set -- "${__argv__[@]}"; unset -v __argv__'

	# shellcheck disable=2142
	alias flag.peek='flag.peek- "$@"; local -a __argv__=() ARGV=("$@"); flag.args __argv__; set -- "${__argv__[@]}"; unset -v __argv__'

	# shellcheck disable=2034
	declare -gr NIL="\0"
}

flag.init-
