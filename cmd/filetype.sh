# cmd/filetype - Filetype detection

# Assert any file type
filetype:any() {
	local -A _=(
		[-zip]=false

		[.help]='FILE [TYPE...]'
		[.argc]=2-
	)

	flag.parse

	local file=$1; shift

	.must "No such file: $file" [[ -f "$file" ]]

	local type
	for type; do
		if filetype:is_ "$type"; then
			return 0
		fi
	done

	return 1
}

# Assert file type
filetype:is() {
	local -A _=(
		[-zip]=false

		[.help]='FILE TYPE'
		[.argc]=2
	)

	flag.parse

	local file=$1; .must "No such file: $file" [[ -f "$file" ]]

	filetype:is_ "$@"
}

# Print mime type
filetype:mime() {
	local -A _=(
		[-zip]=false

		[.help]='FILE'
		[.argc]=1
	)

	flag.parse

	local file=$1; .must "No such file: $file" [[ -f "$file" ]]

	if flag.true -zip; then
		file --mime-type --brief --uncompress-noreport "$file"
	else
		file --mime-type --brief "$file"
	fi
}

# filetype - Protected functions

filetype:is_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local type=${1?${FUNCNAME[0]}: missing argument}; shift

	local func=filetype:is:"${type}"_

	.must "Unable to know type: $type" .callable "$func"

	"$func" "$file" "$@"
}

filetype:shebang_() {
	local    file=${1?${FUNCNAME[0]}: missing argument}; shift
	local -n filetype_shebang_=${1?${FUNCNAME[0]}: missing argument}; shift

	filetype:is:interpretable_ "$file" || return 1

	# shellcheck disable=2034
	local filetype_shebang_string

	filetype_shebang_string_=$(head -n 1 "$file")
	filetype_shebang_string_=${filetype_shebang_string_#\#!}
	filetype_shebang_string_=${filetype_shebang_string_# }

	# shellcheck disable=2034,2206
	filetype_shebang_=($filetype_shebang_string_)
}

# cmd/filetype - Protected functions

filetype:is:compressed_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime; mime=$(file --mime-type --brief "$file")

	case $mime in
	application/gzip|application/zip|application/x-xz|application/x-bzip2|application/x-zstd)
		local zip=$mime; zip=${zip##*/}; zip=${zip##*-}

		if [[ $(file --mime-type --brief --uncompress-noreport "$file") = application/x-tar ]]; then
			_[.file.zip]=tar.$zip
		else
			_[.file.zip]=$zip
		fi

		return 0 ;;
	*)
		return 1 ;;
	esac
}

filetype:is:executable_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	filetype:is:runnable_ "$file" || return 1

	[[ ${_[.file.runnable]:-} = binary ]]
}

filetype:is:interpretable_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	filetype:is:runnable_ "$file" || return 1

	[[ ${_[.file.runnable]:-} = script ]]
}

filetype:is:mime_() {
	local file=${1?${FUNCNAME[0]}: missing argument};     shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime
	if flag.true -zip; then
		mime=$(file --mime-type --brief --uncompress-noreport "$file")
	else
		mime=$(file --mime-type --brief "$file")
	fi

	_[.file.mime]=$mime

	[[ $mime = "$expected" ]]
}

filetype:is:runnable_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime encoding

	IFS='; ' read -r mime encoding < <(file --mime --brief "$file")

	if [[ $encoding =~ binary$ ]]; then
		if [[ $mime  =~ -executable$ ]]; then
			_[.file.runnable]=binary
			return 0
		fi
	else
		if head -n 1 "$file" | grep -q '^#!'; then
			_[.file.runnable]=script
			return 0
		fi
	fi

	return 1
}