# filetype.sh - Filetype detection

filetype.compressed() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime; mime=$(file --mime-type --brief "$file")

	case $mime in
	application/gzip|application/zip|application/x-xz|application/x-bzip2|application/x-zstd)
		local zip=$mime; zip=${zip##*/}; zip=${zip##*-}

		return 0 ;;
	*)
		return 1 ;;
	esac
}

filetype.executable() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime encoding

	IFS='; ' read -r mime encoding < <(file --mime --brief "$file")

	if [[ $encoding =~ binary$ ]]; then
		if [[ $mime  =~ -executable$ ]]; then
			return 0
		fi
	fi

	return 1
}

filetype.interpretable() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime encoding

	IFS='; ' read -r mime encoding < <(file --mime --brief "$file")

	if [[ ! $encoding =~ binary$ ]]; then
		if head -n 1 "$file" | grep -q '^#!' 2>/dev/null; then
			return 0
		fi
	fi

	return 1
}

filetype.mime() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	file --mime-type --brief "$file"
}

filetype.mimez() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	file --mime-type --brief --uncompress-noreport "$file"
}

filetype.runnable() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	local mime encoding

	IFS='; ' read -r mime encoding < <(file --mime --brief "$file")

	if [[ $encoding =~ binary$ ]]; then
		if [[ $mime  =~ -executable$ ]]; then
			return 0
		fi
	else
		if head -n 1 "$file" | grep -q '^#!' 2>/dev/null; then
			return 0
		fi
	fi

	return 1
}

filetype.runnables() {
	local    file=${1?${FUNCNAME[0]}: missing argument};                shift
	local -n filetype_runnables_=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ -d $file ]]; then
		local f
		for f in "$file"/*; do
			filetype.runnable "$f" || continue
			filetype_runnables_+=("$f")
		done
	elif filetype.runnable "$file"; then
		filetype_runnables_+=("$file")
	fi
}

filetype.shebang() {
	local    file=${1?${FUNCNAME[0]}: missing argument}; shift
	local -n lib_filetype_shebang_=${1?${FUNCNAME[0]}: missing argument}; shift

	# shellcheck disable=2034
	local lib_filetype_shebang_string

	lib_filetype_shebang_string_=$(head -n 1 "$file" 2>/dev/null || true)
	lib_filetype_shebang_string_=${lib_filetype_shebang_string_#\#!}
	lib_filetype_shebang_string_=${lib_filetype_shebang_string_# }

	# shellcheck disable=2034,2206
	lib_filetype_shebang_=($lib_filetype_shebang_string_)
}
