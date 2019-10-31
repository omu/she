# ui.sh - UI functions

# Print bug message and exit failure
ui.bug() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.bug "$@"
}

# Print message and exit success
ui.bye() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.bye "$@"
}

# Print message and run command
ui.calling() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1-
	)

	flag.parse

	.calling "$@"
}

# Print warning message
ui.cry() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.cry "$@"
}

# Print error message and exit failure
ui.die() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.die "$@"
}

# Print message indicating a download and run command
ui.getting() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1-
	)

	flag.parse

	.getting "$@"
}

# Print info message
ui.hmm() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.hmm "$@"
}

# Print not ok message
ui.notok() {
	local -A _=(
		[.help]='STRING'
		[.argc]=1
	)

	flag.parse

	.notok "$@"
}

# Print ok message
ui.ok() {
	local -A _=(
		[.help]='STRING'
		[.argc]=1
	)

	flag.parse

	.ok "$@"
}

# Print a busy message run command
ui.running() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1-
	)

	flag.parse

	.calling "$@"
}

# Print message on stderr
ui.say() {
	local -A _=(
		[.help]='MESSAGE'
		[.argc]=1
	)

	flag.parse

	.say "$@"
}

# ui - Protected functions

ui.out() {
	local name=${1:-default}
	shift || true

	local sign=${_sign[$name]}

	# shellcheck disable=2154
	local sign_color=${_sign_color[$name]} text_color=${_text_color[$name]} reset=${_color[reset]}

	echo -en "${sign_color}${sign}${reset} "
	.out "$@"
	echo -en "$reset "
}

# ui - Private functions

# shellcheck disable=2154
ui._echo() {
	[[ $# -gt 0 ]] || return 0

	local message=$1

	local name=${FUNCNAME[1]#*.}

	local sign=${_sign[$name]}

	local sign_color=${_sign_color[$name]} text_color=${_text_color[$name]} reset=${_color[reset]}

	if [[ -n ${sign:-} ]]; then
		echo -e "${sign_color}${sign}${reset} ${text_color}${message}${reset}"
	else
		echo -e "${text_color}${message}${reset}"
	fi
}

# ui - Init

# shellcheck disable=2034,2154
ui._init() {
	declare -Ag _sign _sign_color _text_color

	# Style

	_sign[ask]='?';     _sign_color[ask]=+yellow;    _text_color[ask]=high
	_sign[bug]='✖';     _sign_color[bug]=red;        _text_color[bug]=high
	_sign[cry]='!';     _sign_color[cry]=+yellow;    _text_color[cry]=medium
	_sign[die]='✗';     _sign_color[die]=+red;       _text_color[die]=high
	_sign[hmm]='ℹ';     _sign_color[hmm]=-yellow;    _text_color[hmm]=low
	_sign[say]='' ;     _sign_color[say]=+white;     _text_color[say]=medium

	_sign[notok]='✗';   _sign_color[notok]=+red;     _text_color[notok]=high
	_sign[ok]='✓';      _sign_color[ok]=+green;      _text_color[ok]=high

	_sign[calling]='>'; _sign_color[calling]=+cyan;  _text_color[calling]=high
	_sign[getting]='↓'; _sign_color[getting]=+cyan;  _text_color[getting]=low
	_sign[running]='∙'; _sign_color[running]=+cyan;  _text_color[running]=low
	_sign[default]='∙'; _sign_color[default]=+white; _text_color[default]=medium

	color.expand _sign_color _text_color

	.bug()     { ui._echo "$@" >&2; exit 127; }
	.bye()     { ui._echo "$@" >&2; exit 0;   }
	.calling() { ui._echo "$1" >&2; "${@:2}"; }
	.cry()     { ui._echo "$@" >&2;           }
	.die()     { ui._echo "$@" >&2; exit 1;   }
	.getting() { ui._echo "$1" >&2; "${@:2}"; }
	.hmm()     { ui._echo "$@" >&2;           }
	.notok()   { ui._echo "$@" >&2;           }
	.ok()      { ui._echo "$@" >&2;           }
	.running() { ui._echo "$1" >&2; "${@:2}"; }
	.say()     { ui._echo "$@" >&2;           }
}

ui._init
