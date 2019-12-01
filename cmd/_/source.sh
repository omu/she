declare -gr _SELF=$_SELF

._() {
	case ${1:-} in
	-root)
		[[ ${EUID:-} -eq 0 ]] || { echo >&2 'Root privileges required.'; exit 1; }
		shift
		;;
	esac

	_.die() {
		"$_SELF" die "$@"; exit $?
	}

	_.cry() {
		"$_SELF" cry "$@"
	}

	_.bye() {
		"$_SELF" bye "$@"; exit $?
	}

	_.bug() {
		"$_SELF" bug "$@"; exit $?
	}

	_.must() {
		"$_SELF" must "$@" || exit $?
	}

	_.enter() {
		local dir

		if dir=$("$_SELF" enter "$@") && [[ -n $dir ]]; then
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
	die|cry|bye|bug|must|enter|leave) shift; _."$cmd" "$@" ;;
	*)                                       "$_SELF" "$@" ;;
	esac
}

._ "$@"
