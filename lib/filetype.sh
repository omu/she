# filetype.sh - Filetype detection

# filetype.mime: What mime type
filetype.mime() {
	local -A _=(
		[-zip]=false
	)

	flag.parse "$@"

	local file=${_[1]?${FUNCNAME[0]}: missing value}

	must.f "$file"

	if flag.true zip; then
		file --mime-type --brief --uncompress-noreport "$file"
	else
		file --mime-type --brief "$file"
	fi
}


# is.file: Detect file type
filetype.is() {
	local -A _=(
		[-zip]=false
	)

	flag.parse "$@"

	local -a args; flag.args args

	filetype.is_ "${args[@]}"
}

filetype.is_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local type=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	local func=filetype.is._"${type}"_

	must.func "$func" "Unable to know type: $type"

	"$func" "$file" "$@"
}

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
	local mime encoding

	IFS='; ' read -r mime encoding < <(file --mime --brief "$1")

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
	local mime; mime=$(file --mime-type --brief "$1")

	case $mime in
	gzip|zip|x-xz|x-bzip2|x-zstd)
		local zip=$mime; zip=${zip##*/}; zip=${zip##*-}

		if [[ $(file --mime-type --brief --uncompress-noreport "$file") = tar ]]; then
			_[.file.zip]=tar.$zip
		else
			_[.file.zip]=$zip
		fi

		return 0 ;;
	*)
		return 1 ;;
	esac
}
