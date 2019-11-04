# cmd/zip - Compression/decompression commands

# Unpack compressed file
zip:unpack() {
	local -A _=(
		[-force]=false
		[-clean]=false

		[.help]='[-(force|clean)=BOOL] FILE [DIR]'
		[.argc]=1-
	)

	flag.parse

	local in=$1 out=${2:-};	.must "No such file: $in" [[ -f "$in" ]]

	if [[ -e $out ]]; then
		if flag.true -force; then
			rm -rf -- "$out"
		else
			.die "File already exist: $out"
		fi
	fi

	.must "Not a compressed file of known type: $in" filetype.is_ "$in" compressed

	local func=zip.unpack.${_[.file.zip]:-}

	.must "Unsupported compressed file: $in" .callable "$func"

	"$func" "$in" "$out"

	if flag.true -clean; then
		rm -f -- "$in"
	fi
}
