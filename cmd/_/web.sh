# cmd/web - Operations through web

# Install file from web
web:install() {
	# shellcheck disable=2192
	local -A _=(
		[-group]=
		[-mode]=
		[-owner]=
		[-prefix]=
		[-quiet]=

		[.help]='[-group=GROUP|mode=MODE|owner=USER|prefix=DIR|quiet=BOOL] URL'
		[.argc]=1-
	)

	flag.parse

	local url=$1 dst=${2:-${1##*/}}

	web:install_ "$url" "$dst"
}

# Run program through web
web:run() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='URL'
		[.argc]=1
	)

	flag.parse

	web:run_ "$@"
}

# cmd/web - Protected functions

web:install_() {
	local src=${1?${FUNCNAME[0]}: missing argument}; shift
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	file.download "$src" src
	file:do_ copy "$src" "$dst"
	temp.clean src
}

web:run_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=1007
	local file temp_file_run=

	file.download "$url" temp_file_run
	file=$temp_file_run

	if filetype.runnable "$file"; then
		.must -- chmod +x "$file"
	fi

	file:run_ "$file"
}
