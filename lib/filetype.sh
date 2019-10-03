# filetype.sh - Filetype detection

# filetype.mime: What mime type
filetype.mime() {
	local -A _=(
		[-zip]=false

		[.help]='FILE'
		[.argc]=1
	)

	flag.parse

	local file=$1; must.f "$file"

	if flag.true zip; then
		file --mime-type --brief --uncompress-noreport "$file"
	else
		file --mime-type --brief "$file"
	fi
}


# filetype.is: Detect file type
filetype.is() {
	local -A _=(
		[-zip]=false

		[.help]='FILE'
		[.argc]=1
	)

	flag.parse

	local file=$1; must.f "$file"

	filetype.is_ "$@"
}

# filetype.sh - Protected functions

filetype.is_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local type=${1?${FUNCNAME[0]}: missing argument}; shift

	local func=filetype.is._"${type}"_

	must.callable "$func" "Unable to know type: $type"

	"$func" "$file" "$@"
}

# filetype.sh - Private functions

filetype.is._mime_() {
	local file=${1?${FUNCNAME[0]}: missing argument};     shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime
	if flag.true zip; then
		mime=$(file --mime-type --brief --uncompress-noreport "$file")
	else
		mime=$(file --mime-type --brief "$file")
	fi

	_[.file.mime]=$mime

	[[ $mime = "$expected" ]]
}

filetype.is._program_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime encoding

	IFS='; ' read -r mime encoding < <(file --mime --brief "$file")

	if [[ $encoding =~ binary$ ]]; then
		if [[ $mime  =~ -executable$ ]]; then
			_[.file.program]=binary
			return 0
		fi
	else
		if head -n 1 "$file" | grep -q '^#!'; then
			_[.file.program]=script
			return 1
		fi
	fi

	return 1
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
