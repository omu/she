# text.sh - Text blob manipulations

# text.fix: Append stdin content to the target file
text.fix() {
	local file=${1?missing argument: file}

	text.unfix "$file"

	{
		echo '# BEGIN FIX'
		cat
		echo '# END FIX'
	} >>"$file"
}

# text.fix: Remove appended content
text.unfix() {
	local file=${1?missing argument: file}

	text.fixed "$file" || return 0

	[[ -w $file ]] || die "File not writable: $file"

	sed -i '/BEGIN FIX/,/END FIX/d' "$file"
}

text.fixed() {
	local file=${1?missing argument: file}

	[[ -f $file ]] || die "File not found: $file"

	grep -qE '(BEGIN|END) FIX' "$file"
}
