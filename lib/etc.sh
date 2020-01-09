# etc.sh - Simple configuration management

# shellcheck disable=2034
etc.get() {
	local prefix="${1?${FUNCNAME[0]}: missing argument}";      shift
	local bucket="${1?${FUNCNAME[0]}: missing argument}";      shift
	local -n etc_get_="${1?${FUNCNAME[0]}: missing argument}"; shift

	local dir
	dir=$(etc.bucket- "$prefix" "$bucket")

	local -a args=("$@")

	if [[ "${#args[@]}" -eq 0 ]]; then
		if [[ -d $dir ]]; then
			local f
			for f in "$dir"/*; do
				if [[ -f $f ]] && [[ -r $f ]]; then
					args+=("${f##*/}")
				fi
			done
		fi
	fi

	local -A variable=()

	local arg name value

	for arg in ${args[@]+"${args[@]}"}; do
		if [[ "$arg" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
			name=$arg
			[[ -r $dir/$name ]] || continue

			value=$(<"$dir/$name")
			variable[$name]=$value
		else
			.die "Invalid variable name: $arg"
		fi
	done

	[[ "${#variable[@]}" -gt 0 ]] || return 0

	.merge etc_get_ variable
}

etc.reset() {
	local prefix="${1?${FUNCNAME[0]}: missing argument}"; shift
	local bucket="${1?${FUNCNAME[0]}: missing argument}"; shift

	local dir
	dir=$(etc.bucket- "$prefix" "$bucket")

	.must -- rm -rf "$dir"
}

# shellcheck disable=2034
etc.set() {
	local prefix="${1?${FUNCNAME[0]}: missing argument}";      shift
	local bucket="${1?${FUNCNAME[0]}: missing argument}";      shift
	local -n etc_set_="${1?${FUNCNAME[0]}: missing argument}"; shift

	local dir
	dir=$(etc.bucket- "$prefix" "$bucket")

	local -a args=("$@")

	if [[ "${#args[@]}" -eq 0 ]]; then
		if [[ -d $dir ]]; then
			local f
			for f in "$dir"/*; do
				if [[ -f $f ]] && [[ -r $f ]]; then
					args+=("${f##*/}")
				fi
			done
		fi
	fi

	local -A variable=()
	local -a writes=()

	local arg name value

	for arg in ${args[@]+"${args[@]}"}; do
		if [[ "$arg" =~ ^[a-zA-Z_][a-zA-Z0-9_]*= ]]; then
			name=${arg%%=*}
			value=${arg#$name=}

			variable[$name]=$value
			writes+=("$name")
		elif [[ "$arg" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
			.die "Value requiredi for variable: $arg"
		else
			.die "Invalid variable name: $arg"
		fi
	done

	if [[ ${#writes[@]} -gt 0 ]]; then
		etc.prep- "$prefix"

		[[ -d $dir ]] || .must -- mkdir -p "$dir"
		for name in "${writes[@]}"; do
			echo "${variable[$name]-}" >"$dir/$name"
		done
	fi

	[[ "${#variable[@]}" -gt 0 ]] || return 0

	.merge etc_set_ variable
}

etc.bucket-() {
	local prefix="${1?${FUNCNAME[0]}: missing argument}"; shift
	local bucket="${1?${FUNCNAME[0]}: missing argument}"; shift

	local dir

	case $bucket in
	""|.|/)
		dir=$bucket
		;;
	*)
		dir=$prefix/$bucket
		;;
	esac

	.must -- readlink -m "$dir"
}

etc.prep-() {
	local prefix="${1?${FUNCNAME[0]}: missing argument}"; shift

	mkdir -p "$prefix" || .die "Prefix directory not writable: $prefix"
}
