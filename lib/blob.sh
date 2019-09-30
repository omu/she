# blob.unpack: Unpack blob
blob.unpack() {
	local type=${1?${FUNCNAME[0]}: missing argument};  shift
	local in=${1?${FUNCNAME[0]}: missing argument};    shift
	local out=${1?${FUNCNAME[0]}: missing argument};   shift

	must.f "$in"

	has.function blob._unpack."$type" || die "Unrecognized file type: $type"

	blob._unpack."$type" "$in" "$out"
}

blob._unpack.tar.gz() {
	tar --strip-components=1 -zxvf "$1" -C "$2"
}

blob._unpack.tar.bz2() {
	tar --strip-components=1 -jxvf "$1" -C "$2"
}

blob._unpack.tar.xz() {
	tar --strip-components=1 -Jxvf "$1" -C "$2"
}

blob._unpack.tar.zxstd() {
	tar -I zstd -xvf "$1" -C "$2"
}

blob._unpack.zip() {
	unzip -q -d "$2" "$1"
}

blob._unpack.gz() {
	local tempfile
	temp.file tempfile

	zcat "$1" >"$tempfile" && mv "$tempfile" "$2"
}

blob._unpack.bz2() {
	local tempfile
	temp.file tempfile

	bzcat "$1" >"$tempfile" && mv "$tempfile" "$2"
}

blob._unpack.xz() {
	local tempfile
	temp.file tempfile

	unxz "$1" >"$tempfile" && mv "$tempfile" "$2"
}

blob._unpack.zstd() {
	local tempfile
	temp.file tempfile

	zstdcat -f "$1" >"$tempfile" && mv "$tempfile" "$2"
}

