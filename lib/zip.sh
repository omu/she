zip.unpack() {
	local in=${1?${FUNCNAME[0]}: missing argument}; shift
	local out=${1:-}

	local ext=${in##*.}
	.must "Extension required: $in" [[ -n "$ext" ]]

	local type
	case $in in
	*.tar.*) type=tar.$ext ;;
	*)       type=$ext     ;;
	esac

	[[ -n $out ]] || out=${in%.*}
	.must "Destination already exists: $out" [[ ! -e "$out" ]]

	local func=zip.unpack."$type"

	.must "Unsupported compressed file: $in" .callable "$func"

	"$func" "$in" "$out"
}

zip.unpack.bz2() {
	.must 'No program found: bzcat' .available bzcat && zip.prep-unzip- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	local temp_file
	temp.file temp_file

	bzcat "$in" >"$temp_file" && mv "$temp_file" "$out"
}

zip.unpack.gz() {
	.must 'No program found: zcat' .available zcat && zip.prep-unzip- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip.prep-unzip- zcat

	local temp_file
	temp.file temp_file

	zcat "$in" >"$temp_file" && mv "$temp_file" "$out"
}

zip.unpack.tar.bz2() {
	.must 'No program found: bzip2' .available bzip2 && zip.prep-untar- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	tar --strip-components=1 -jxf "$in" -C "$out"
}

zip.unpack.tar.gz() {
	zip.prep-untar- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	tar --strip-components=1 -zxf "$in" -C "$out"
}

zip.unpack.tar.xz() {
	.must 'No program found: xz' .available xz && zip.prep-untar- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	tar --strip-components=1 -Jxf "$in" -C "$out"
}

zip.unpack.tar.zst() {
	.must 'No program found: zstd' .available zstd && zip.prep-untar- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	tar --strip-components=1 --zstd -xf "$in" -C "$out"
}

zip.unpack.xz() {
	.must 'No program found: unxz' .available unxz && zip.prep-unzip- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	local temp_file
	temp.file temp_file

	unxz "$in" >"$temp_file" && mv "$temp_file" "$out"
}

zip.unpack.zip() {
	.must 'No program found: unzip' .available unzip && zip.prep-unzip- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	unzip -q -d "$out" "$in"
}

zip.unpack.zst() {
	.must 'No program found: zstdcat' .available zstdcat && zip.prep-unzip- "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	local temp_file
	temp.file temp_file

	zstdcat -f "$in" >"$temp_file" && mv "$temp_file" "$out"
}

# zip - Private functions

zip.prep-untar-() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	[[ -n $out ]] || out=${in%.tar.*}

	if [[ -e $out ]]; then
		.die "Directory already exist: $out"
	fi

	.must -- mkdir -p "$out"
}

zip.prep-unzip-() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	[[ -n $out ]] || out=${in%.*}

	if [[ -e $out ]]; then
		.die "File already exist: $out"
	fi
}
