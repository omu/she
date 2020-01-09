# temp.sh - Functions involving temporary directories or files

# Remove temp files or directories
temp.clean() {
	while [[ $# -gt 0 ]]; do
		local -n temp_clean_=$1; shift

		rm -rf -- "$temp_clean_"
	done
}

# Create a temp dir
temp.dir() {
	# shellcheck disable=2155
	local -n temp_dir_=${1?${FUNCNAME[0]}: missing argument}; shift

	local dir

	# shellcheck disable=2128
	dir=$(mktemp -p "${TMPDIR:-/tmp}" -d "$PROGNAME".XXXXXXXX) || .die 'Fatal error: mktemp'
	.clean "$dir"

	# shellcheck disable=2034
	temp_dir_=$dir
}

# Create a temp file
temp.file() {
	# shellcheck disable=2155
	local -n temp_file_=${1?${FUNCNAME[0]}: missing argument}; shift

	local file

	# shellcheck disable=2128
	file=$(mktemp -p "${TMPDIR:-/tmp}" "$PROGNAME".XXXXXXXX) || .die 'Fatal error: mktemp'
	.clean "$file"

	# shellcheck disable=2034
	temp_file_=$file
}

# Execute command in a temp dir
temp.inside() {
	# shellcheck disable=2128
	local temp_inside_ orig_dir_=$PWD
	temp.dir temp_inside_

	.must -- cd "$temp_inside_"
	"$@"
	.must -- cd "$orig_dir_"

	rm -rf -- "$temp_inside_"
}
