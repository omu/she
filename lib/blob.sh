# blob.unpack: Unpack blob
blob.unpack() {
	local in=${1?${FUNCNAME[0]}: missing argument};   shift
	local out=${1?${FUNCNAME[0]}: missing argument};  shift

	must.f "$in"

	local -A _

	file.is_ compressed "$in" || die "Not a compressed file of known type: $in"

	local func=blob._unpack.${_[.file.zip]:-}

	must.func "$func" "Unsupported compressed file type: $zip"

	"$func" "$in" "$out"
}

blob._unpack.tar.gz() {
	tar --strip-components=1 -zxvf "$1" -C "$2"
}

blob._unpack.tar.bz2() {
	must.available bzip2

	tar --strip-components=1 -jxvf "$1" -C "$2"
}

blob._unpack.tar.xz() {
	must.available xz

	tar --strip-components=1 -Jxvf "$1" -C "$2"
}

blob._unpack.tar.zst() {
	must.available zstd

	tar --strip-components=1 --zstd -xvf "$1" -C "$2"
}

blob._unpack.zip() {
	must.available unzip

	unzip -q -d "$2" "$1"
}

blob._unpack.gz() {
	local tempfile
	temp.file tempfile

	zcat "$1" >"$tempfile" && mv "$tempfile" "$2"
}

blob._unpack.bz2() {
	must.available bzcat

	local tempfile
	temp.file tempfile

	bzcat "$1" >"$tempfile" && mv "$tempfile" "$2"
}

blob._unpack.xz() {
	must.available unxz

	local tempfile
	temp.file tempfile

	unxz "$1" >"$tempfile" && mv "$tempfile" "$2"
}

blob._unpack.zst() {
	must.available zstdcat

	local tempfile
	temp.file tempfile

	zstdcat -f "$1" >"$tempfile" && mv "$tempfile" "$2"
}
