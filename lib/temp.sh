# temp.sh - Functions involving temporary directories or files

temp.file() {
	# shellcheck disable=2155
	local -n temp_file_=${1?${FUNCNAME[0]}: missing argument}; shift

	local file

	# shellcheck disable=2128
	file=$(mktemp -p "${TMPDIR:-/tmp}" "$PROGNAME".XXXXXXXX) || .die 'Fatal error: mktemp'
	at_exit_files "$file"

	# shellcheck disable=2034
	temp_file_=$file
}

temp.dir() {
	# shellcheck disable=2155
	local -n temp_dir_=${1?${FUNCNAME[0]}: missing argument}; shift

	local dir

	# shellcheck disable=2128
	dir=$(mktemp -p "${TMPDIR:-/tmp}" -d "$PROGNAME".XXXXXXXX) || .die 'Fatal error: mktemp'
	at_exit_files "$dir"

	# shellcheck disable=2034
	temp_dir_=$dir
}

# Execute command in temp dir
temp.inside() {
	local temp_dir orig_dir=$PWD
	temp.dir temp_dir

	must.success cd "$temp_dir"
	"$@"
	must.success cd "$orig_dir"

	rm -rf -- "$temp_dir"
}

temp.clean() {
	while [[ $# -gt 0 ]]; do
		local -n temp_clean_=$1; shift

		[[ -z ${!temp_clean_:-} ]] || rm -f -- "${!temp_clean_}"
	done
}
