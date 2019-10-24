# ui.sh - UI functions

# shellcheck disable=2034,2154
ui._init() {
	declare -Ag _sign _sign_color _text_color

	# Style

	_sign[caution]='★';    _sign_color[caution]=+cyan;      _text_color[caution]=high
	_sign[failure]='✗';    _sign_color[failure]=+red;       _text_color[failure]=high
	_sign[headline]='>';   _sign_color[headline]=+cyan;     _text_color[headline]=high
	_sign[info]='ℹ';       _sign_color[info]=-yellow;       _text_color[info]=low
	_sign[panic]='✖';      _sign_color[panic]=red;          _text_color[panic]=high
	_sign[plain]=' ';      _sign_color[plain]=+white;       _text_color[plain]=medium
	_sign[question]='?';   _sign_color[question]=+yellow;   _text_color[question]=high
	_sign[success]='✓';    _sign_color[success]=+green;     _text_color[success]=high
	_sign[warning]='!';    _sign_color[warning]=+yellow;    _text_color[warning]=medium

	color.expand _sign_color _text_color
}

# shellcheck disable=2034,2154
ui._echo() {
	local name=${FUNCNAME[1]#*.}

	local sign=${_sign[$name]}

	local sign_color=${_sign_color[$name]} text_color=${_text_color[$name]} reset=${_color[reset]}

	echo -e "${sign_color}${sign}${reset} ${text_color}$*${reset}"
}

ui.caution()  { ui._echo "$@"; }
ui.failure()  { ui._echo "$@"; }
ui.headline() { ui._echo "$@"; }
ui.info()     { ui._echo "$@"; }
ui.panic()    { ui._echo "$@"; }
ui.plain()    { ui._echo "$@"; }
ui.question() { ui._echo "$@"; }
ui.success()  { ui._echo "$@"; }
ui.warning()  { ui._echo "$@"; }

# Report bug and exit failure
ui.bug() {
	ui.panic "$@" >&2; exit 127
}

# Print messages on standard error
ui.say() {
	ui.plain "$@" >&2
}

# Print messages on standard error and exit success
ui.bye() {
	ui.plain "$@" >&2; exit 0
}

# Print warning messages on standard error
ui.cry() {
	ui.warning "$@" >&2
}

# Print error messages and exit failure
ui.die() {
	ui.failure "$@" >&2; exit 1
}

# Print messages taking attention
ui.hey() {
	ui.headline "$@" >&2
}

ui._init

shopt -s expand_aliases

alias .bug=ui.bug
alias .bye=ui.bye
alias .cry=ui.cry
alias .die=ui.die
alias .hey=ui.hey

ui.out() {
	local name=$1
	shift

	local sign=${_sign[$name]}

	local sign_color=${_sign_color[$name]} text_color=${_text_color[$name]} reset=${_color[reset]}

	echo -en "${sign_color}${sign}${reset} "
	.out
	echo -en "$reset "
}
