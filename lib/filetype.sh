# filetype.sh - Filetype detection

# Detect mime type
filetype.mime() {
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

# Assert any file type
filetype.any() {
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
		if filetype.is_ "$type"; then
			return 0
		fi
	done

	return 1
}

# Assert file type
filetype.is() {
	local -A _=(
		[-zip]=false

		[.help]='FILE TYPE'
		[.argc]=2
	)

	flag.parse

	local file=$1; .must "No such file: $file" [[ -f "$file" ]]

	filetype.is_ "$@"
}

# filetype - Protected functions

filetype.is_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local type=${1?${FUNCNAME[0]}: missing argument}; shift

	local func=filetype.is._"${type}"_

	.must "Unable to know type: $type" .callable "$func"

	"$func" "$file" "$@"
}

# filetype - Private functions

filetype.is._mime_() {
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

filetype.is._runnable_() {
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

filetype.is._interpretable_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	filetype.is._runnable_ "$file" || return 1

	[[ ${_[.file.runnable]:-} = script ]]
}

filetype.is._executable_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	filetype.is._runnable_ "$file" || return 1

	[[ ${_[.file.runnable]:-} = binary ]]
}

filetype.is._compressed_() {
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

filetype.shebang_() {
	local    file=${1?${FUNCNAME[0]}: missing argument}; shift
	local -n filetype_shebang_=${1?${FUNCNAME[0]}: missing argument}; shift

	filetype.is._interpretable_ "$file" || return 1

	local shebang

	shebang=$(head -n 1 "$file")
	shebang=${shebang#\#!}
	shebang=${shebang# }

	# shellcheck disable=2034,2206
	filetype_shebang_=($shebang)
}
