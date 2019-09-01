.() {
	declare -grx UNDERSCORE=$UNDERSCORE

	case ${1:-} in
	-root)
		[[ ${EUID:-} -eq 0 ]] || abort 'Root privileges required.'
		;;
	esac

	_.die() {
		"$UNDERSCORE" die "$@"; exit $?
	}

	_.fin() {
		"$UNDERSCORE" fin "$@"; exit $?
	}

	_.bug() {
		"$UNDERSCORE" fin "$@"; exit $?
	}

	_.enter() {
		local dir

		if dir=$("$UNDERSCORE" enter "$@") && [[ -n $dir ]]; then
			pushd "$dir" &>/dev/null || exit
		fi
	}

	_.leave() {
		popd &>/dev/null || exit
	}

	unset -f "${FUNCNAME[0]}"
}

_() {
	local cmd=$1

	case $cmd in
	die|fin|bug|enter|leave) shift; _."$cmd" "$@" ;;
	*)                       "$UNDERSCORE" "$@" ;;
	esac
}
