# color.sh - Colors

# shellcheck disable=2034
color.init() {
	declare -Ag _color=(
		# Basic colors with variants - prefix +: bold, prefix -: dim, suffix -: reverse

		[black]='\e[38;5;8m'          [+black]='\e[1m\e[38;5;8m'     [-black]='\e[38;5;0m'
		[black-]='\e[48;5;8m'         [+black-]='\e[1m\e[48;5;8m'    [-black-]='\e[48;5;0m'

		[blue]='\e[38;5;12m'          [+blue]='\e[1m\e[38;5;12m'     [-blue]='\e[38;5;4m'
		[blue-]='\e[48;5;12m'         [+blue-]='\e[1m\e[48;5;12m'    [-blue-]='\e[48;5;4m'

		[cyan]='\e[38;5;14m'          [+cyan]='\e[1m\e[38;5;14m'     [-cyan]='\e[38;5;6m'
		[cyan-]='\e[48;5;14m'         [+cyan-]='\e[1m\e[48;5;14m'    [-cyan-]='\e[48;5;6m'

		[green]='\e[38;5;10m'         [+green]='\e[1m\e[38;5;10m'    [-green]='\e[38;5;2m'
		[green-]='\e[48;5;10m'        [+green-]='\e[1m\e[48;5;10m'   [-green-]='\e[48;5;2m'

		[magenta]='\e[38;5;13m'       [+magenta]='\e[1m\e[38;5;13m'  [-magenta]='\e[38;5;5m'
		[magenta-]='\e[48;5;13m'      [+magenta-]='\e[1m\e[48;5;13m' [-magenta-]='\e[48;5;5m'

		[red]='\e[38;5;9m'            [+red]='\e[1m\e[38;5;9m'       [-red]='\e[38;5;1m'
		[red-]='\e[48;5;9m'           [+red-]='\e[1m\e[48;5;9m'      [-red-]='\e[48;5;1m'

		[white]='\e[38;5;15m'         [+white]='\e[1m\e[38;5;15m'    [-white]='\e[38;5;7m'
		[white-]='\e[48;5;15m'        [+white-]='\e[1m\e[48;5;15m'   [-white-]='\e[48;5;7m'

		[yellow]='\e[38;5;11m'        [+yellow]='\e[1m\e[38;5;11m'   [-yellow]='\e[38;5;3m'
		[yellow-]='\e[48;5;11m'       [+yellow-]='\e[1m\e[48;5;11m'  [-yellow-]='\e[48;5;3m'

		# Attributes

		[bold]='\e[1m'                [dark]='\e[2m'                 [underlined]='\e[4m'
		[blink]='\e[5m'               [reverse]='\e[7m'              [reset]='\e[0m'

		# Priority aliases
		[high]='\e[1m'                [medium]=''                    [low]='\e[2m'
	)
}

color.init

color.expand() {
	while [[ $# -gt 0 ]]; do
		local -n color_expand_=${1?missing argument}
		shift

		local key value
		for key in "${!color_expand_[@]}"; do
			value=${color_expand_[$key]}

			color_expand_[$key]=${_color[$value]}
		done
	done
}

color.setup() {
	while [[ $# -gt 0 ]]; do
		local key=${1%%=*}; value=${1#*=}

		if [[ -n ${_color[$value]:-} ]]; then
			_color[$key]=${_color[$value]}
		else
			_color[$key]=$value
		fi

		shift
	done
}

color.code() {
	local name="${1?${FUNCNAME[0]}: missing argument}"; shift
	local code="${_color[$name]:-}"

	[[ -n $code ]] || .bug "No such color: $name"

	echo -en "$code"
}

color.out() {
	local color="${1?${FUNCNAME[0]}: missing argument}"; shift

	local code reset

	code=$(color.code "$color")
	reset=$(color.code reset)

	echo -en "$code"
	.out
	echo -en "$reset"
}

color.echo() {
	local color="${1?${FUNCNAME[0]}: missing argument}"; shift

	local code reset
	code=$(color.code "$color")
	reset=$(color.code reset)

	echo -e "${code}${*}${reset}"
}
