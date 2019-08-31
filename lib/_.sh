_() {
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

	local cmd=$1

	case $cmd in
	die|fin|bug|enter|leave) shift; _."$cmd" "$@" ;;
	*)                       "$UNDERSCORE" "$@" ;;
	esac
}
