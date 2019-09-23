# temp.sh - Functions involving temporary directories or files

temp.file() {
	# shellcheck disable=2155
	local -n temp_file_=${1?missing 1th argument: name reference}

	local file

	file=$(mktemp -p "${TMPDIR:-/tmp}" "$PROGNAME".XXXXXXXX) || die 'Fatal error: mktemp'
	at_exit_files "$file"

	# shellcheck disable=2034
	temp_file_=$file
}

temp.dir() {
	# shellcheck disable=2155
	local -n temp_dir_=${1?missing 1th argument: name reference}

	local dir
	dir=$(mktemp -p "${TMPDIR:-/tmp}" -d "$PROGNAME".XXXXXXXX) || die 'Fatal error: mktemp'
	at_exit_files "$dir"

	# shellcheck disable=2034
	temp_dir_=$dir
}

# temp.inside: Execute command in temp dir and (optionally) move it elsewhere
temp.inside() {
	local temp_dir orig_dir=$PWD
	temp.dir temp_dir

	must cd "$temp_dir"
	"$@"
	must cd "$orig_dir"

	rm -rf -- "$temp_dir"
}

temp.clean() {
	local -n temp_clean_=${1?missing 1th argument: name reference}

	[[ -z ${!temp_clean_:-} ]] || rm -f -- "${!temp_clean_}"
}
