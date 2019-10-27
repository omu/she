# zip.sh - Compression/decompression functions

# Unpack compressed file
zip.unpack() {
	local -A _=(
		[-force]=false
		[-clean]=false

		[.help]='[-(force|clean)=BOOL] FILE [DIR]'
		[.argc]=1-
	)

	flag.parse

	local in=$1 out=${2:-};	.must "No such file: $in" [[ -f "$in" ]]

	.must "Not a compressed file of known type: $in" filetype.is_ "$in" compressed

	local func=zip._unpack_.${_[.file.zip]:-}

	.must "Unsupported compressed file: $in" .callable "$func"

	"$func" "$in" "$out"

	if flag.true -clean; then
		rm -f -- "$in"
	fi
}

zip._unpack_.tar.gz() {
	zip._prep_untar_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	tar --strip-components=1 -zxf "$in" -C "$out"
}

zip._unpack_.tar.bz2() {
	.must 'No program found: bzip2' .available bzip2 && zip._prep_untar_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	tar --strip-components=1 -jxf "$in" -C "$out"
}

zip._unpack_.tar.xz() {
	.must 'No program found: xz' .available xz && zip._prep_untar_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	tar --strip-components=1 -Jxf "$in" -C "$out"
}

zip._unpack_.tar.zst() {
	.must 'No program found: zstd' .available zstd && zip._prep_untar_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	tar --strip-components=1 --zstd -xf "$in" -C "$out"
}

zip._unpack_.zip() {
	.must 'No program found: unzip' .available unzip && zip._prep_unzip_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	unzip -q -d "$out" "$in"
}

zip._unpack_.gz() {
	.must 'No program found: zcat' .available zcat && zip._prep_unzip_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_unzip_ zcat

	local temp_file
	temp.file temp_file

	zcat "$in" >"$temp_file" && mv "$temp_file" "$out"
}

zip._unpack_.bz2() {
	.must 'No program found: bzcat' .available bzcat && zip._prep_unzip_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	local temp_file
	temp.file temp_file

	bzcat "$in" >"$temp_file" && mv "$temp_file" "$out"
}

zip._unpack_.xz() {
	.must 'No program found: unxz' .available unxz && zip._prep_unzip_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	local temp_file
	temp.file temp_file

	unxz "$in" >"$temp_file" && mv "$temp_file" "$out"
}

zip._unpack_.zst() {
	.must 'No program found: zstdcat' .available zstdcat && zip._prep_unzip_ "$@"

	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	local temp_file
	temp.file temp_file

	zstdcat -f "$in" >"$temp_file" && mv "$temp_file" "$out"
}

zip._prep_unzip_() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	[[ -n $out ]] || out=${in%.*}

	if [[ -e $out ]]; then
		if flag.true -force; then
			rm -rf -- "$out"
		else
			.die "File already exist: $out"
		fi
	fi
}

zip._prep_untar_() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	[[ -n $out ]] || out=${in%.tar.*}

	if [[ -e $out ]]; then
		if flag.true -force; then
			rm -rf -- "$out"
		else
			.die "Directory already exist: $out"
		fi
		.must -- mkdir -p "$out"
	else
		.must -- mkdir -p "$out"
	fi
}
