discover() {
	: # nop
}

# shellcheck disable=2128
focus() {
	local -n x=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ -n ${x[center]:-} ]]; then
		.must -- cd "${x[center]}"

		return 0
	fi

	.must -- cd "${x[target]}"

	while :; do
		if [[ -f .META ]] || [[ -d .git ]]; then
			return 0
		fi

		if [[ $PWD == "/" ]]; then
			break
		fi

		.must -- cd ..
	done
}

setup() {
	: # nop
}

handle() {
	local -n x=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ $# -eq 0 ]]; then
		discover

		return 0
	fi

	local cmd=$1; shift

	local pattern found
	for pattern in 'bin/%s' 'sbin/%s' 'script/%s' 'scripts/%s.sh'; do # FIXME
		local file

		# shellcheck disable=2059
		printf -v file "$pattern" "$cmd"

		if [[ -f $file ]]; then
			found=$file
			break
		fi
	done

	[[ -n ${found:-} ]] || .die 'No runnable found'

	filetype.runnable "$found" || .die "Not a runnable: $found"

	file.run "$found" "$@"
}
