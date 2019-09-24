# flag.sh - Flag handling

flag.parse() {
	if [[ ${#_[@]} -gt 1 ]]; then
		flag.parse_strict_ "$@"
	else
		flag.parse_loose_ "$@"
	fi
}

flag.args() {
	local -n flag_args_=$1

	local -i i
	for i in {1..9}; do
		if [[ -v _[$i] ]]; then
			flag_args_+=("${_[$i]}")
		fi
	done
}

flag.true() {
	bool "${_[-$1]:-}"
}

flag.false() {
	! flag.true "$@"
}

flag.dump() {
	hmm _
}

flag.overlay() {
	local -i i=1

	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
			_["$key"]=$value
		elif [[ $1 == '--' ]]; then
			shift
			break
		else
			# shellcheck disable=2154
			_[error]="Non flag or key: $1"
			return 1
		fi

		shift
	done
}

flag.underlay() {
	local -i i=1

	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
			[[ -v _[$key] ]] || _["$key"]=$value
		elif [[ $1 == '--' ]]; then
			shift
			break
		else
			_[error]="Non flag or key: $1"
			return 1
		fi

		shift
	done
}

flag.parse_strict_() {
	local -i i=1

	while [[ $# -gt 0 ]]; do
		local key value

		if [[ $1 =~ ^-*[[:alpha:]_][[:alnum:]_]*= ]]; then
			key=${1%%=*}; value=${1#*=}
			if [[ $key =~ ^-.+$ ]] && [[ ! -v _[$key] ]]; then
				_[error]="Unrecognized flag: $key"

				return 1
			fi
		elif [[ $1 == '--' ]]; then
			shift
			break
		else
			key=$((i++)); value=$1
		fi

		_["$key"]=$value

		shift
	done
}

flag.parse_loose_() {
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

		_["$key"]=$value

		shift
	done
}
