# callback.sh - Handle callback functions

.callback() {
	local group=${1?${FUNCNAME[0]}: missing argument}; shift

	local -a _callback_funcs_

	mapfile -t _callback_funcs_ < <(
		shopt -s extdebug

		declare -F | awk '/^declare -f '"$group"'[.]/ { print $3 }' |
		while read -r func; do declare -F "$func"; done |
		sort -t' ' -k2 -n | cut -f1 -d' '
	)

	local func

	local -a _callback_early_ _callback_now_ _callback_late_

	for func in "${_callback_funcs_[@]}"; do
		case $func in
		*_early|*.early_|*.early) _callback_early_+=("$func") ;;
		*_late|*.late_|*.late)    _callback_late_+=("$func")  ;;
		*)                        _callback_now_+=("$func")   ;;
		esac
	done

	local failer=$group.fail
	.callable "$failer" || failer=.callback-fail-default-

	local -i err=0

	for func in "${_callback_early_[@]}"; do
		"$func" "$@" || { "$failer" "$func" "$@"; err+=1; }
	done

	for func in "${_callback_now_[@]}"; do
		"$func" "$@" || { "$failer" "$@"; err+=1; }
	done

	for func in "${_callback_late_[@]}"; do
		"$func" "$@" ||  { "$failer" "$@"; err+=1; }
	done

	return $err
}

# callback - Private functions

.callback-fail-default-() {
	local func=${1?${FUNCNAME[0]}: missing argument}; shift

	case ${SIGNAL:-} in
	INT|QUIT) return 0 ;;
	esac

	.cry "Callback failed: $func"
}
