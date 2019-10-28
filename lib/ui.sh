# ui.sh - UI functions

# shellcheck disable=2034,2154
ui.init() {
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
}

ui.init

.ask()     { ui.do "$@";          }
.bug()     { ui.do "$@" exit 127; }
.bye()     { ui.do "$@" exit 0;   }
.cry()     { ui.do "$@";          }
.die()     { ui.do "$@" exit 1;   }
.hmm()     { ui.do "$@";          }
.say()     { ui.do "$@";          }

.ok()      { ui.do "$@";          }
.notok()   { ui.do "$@";          }

.calling() { ui.do "$@";          }
.getting() { ui.do "$@";          }
.running() { ui.do "$@";          }

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

# shellcheck disable=2034,2154
ui.do() {
	local message="${1?${FUNCNAME[0]}: missing argument}"; shift

	local name=${FUNCNAME[1]#*.}

	local sign=${_sign[$name]}

	local sign_color=${_sign_color[$name]} text_color=${_text_color[$name]} reset=${_color[reset]}

	echo -e "${sign_color}${sign}${reset} ${text_color}${message}${reset}" >&2

	"$@"
}
