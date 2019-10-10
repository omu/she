declare -grx UNDERSCORE=$UNDERSCORE

.() {
	case ${1:-} in
	-root)
		[[ ${EUID:-} -eq 0 ]] || { echo >&2 'Root privileges required.'; exit 1; }
		shift
		;;
	esac

	_.die() {
		"$UNDERSCORE" die "$@"; exit $?
	}

	_.cry() {
		"$UNDERSCORE" cry "$@"
	}

	_.bye() {
		"$UNDERSCORE" bye "$@"; exit $?
	}

	_.bug() {
		"$UNDERSCORE" bug "$@"; exit $?
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
	die|cry|bye|bug|enter|leave) shift; _."$cmd" "$@" ;;
	*)                       "$UNDERSCORE" "$@"   ;;
	esac
}

# shellcheck disable=1090
. "$@"
