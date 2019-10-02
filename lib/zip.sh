# unzip: Unpack compressed file
zip.unpack() {
	local -A _=(
		[-force]=false
		[-clean]=false

		[.help]='file'
		[.argc]=1-
	)

	flag.parse

	local in=$1 out=${2:-};	must.f "$in"

	filetype.is_ "$in" compressed || die "Not a compressed file of known type: $in"

	local func=zip._unpack_.${_[.file.zip]:-}

	must.callable "$func" "Unsupported compressed file: $in"

	"$func" "$in" "$out"

	if flag.true clean; then
		rm -f -- "$in"
	fi
}

zip._unpack_.tar.gz() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_untar_

	tar --strip-components=1 -zxvf "$in" -C "$out"
}

zip._unpack_.tar.bz2() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_untar_ bzip2

	tar --strip-components=1 -jxvf "$in" -C "$out"
}

zip._unpack_.tar.xz() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_untar_ xz

	tar --strip-components=1 -Jxvf "$in" -C "$out"
}

zip._unpack_.tar.zst() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_untar_ zstd

	tar --strip-components=1 --zstd -xvf "$in" -C "$out"
}

zip._unpack_.zip() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_unzip_ unzip

	unzip -q -d "$out" "$in"
}

zip._unpack_.gz() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_unzip_ zcat

	local tempfile
	temp.file tempfile

	zcat "$in" >"$tempfile" && mv "$tempfile" "$out"
}

zip._unpack_.bz2() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_unzip_ bzcat

	local tempfile
	temp.file tempfile

	bzcat "$in" >"$tempfile" && mv "$tempfile" "$out"
}

zip._unpack_.xz() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_unzip_ unxz

	local tempfile
	temp.file tempfile

	unxz "$in" >"$tempfile" && mv "$tempfile" "$out"
}

zip._unpack_.zst() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	zip._prep_unzip_ zstdcat

	local tempfile
	temp.file tempfile

	zstdcat -f "$in" >"$tempfile" && mv "$tempfile" "$out"
}

zip._prep_unzip_() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	local prog
	for prog; do
		must.available "$prog"
	done

	[[ -n $out ]] || out=${in%.*}

	if [[ -e $out ]]; then
		if flag.true force; then
			must.success rm -rf -- "$out"
		else
			die "File already exist: $out"
		fi
	fi
}

zip._prep_untar_() {
	local in=${1?${FUNCNAME[0]}: missing argument}; out=${2:-}

	local prog
	for prog; do
		must.available "$prog"
	done

	[[ -n $out ]] || out=${in%.tar.*}

	if [[ -e $out ]]; then
		if flag.true force; then
			must.success rm -rf -- "$out"
		else
			die "Directory already exist: $out"
		fi
		must.success mkdir -p "$out"
	else
		must.success mkdir -p "$out"
	fi
}
