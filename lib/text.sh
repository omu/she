# text.sh - Text blob manipulations

# text.fix: Append stdin content to the target file
text.fix() {
	local -A _=(
		[.help]='file'
		[.argc]=1
	)

	flag.parse "$@"

	local file=${_[1]}
	must.f "$file"

	text._unfix "$file"

	{
		echo '# BEGIN FIX'
		cat
		echo '# END FIX'
	} >>"$file"
}

# text.unfix: Remove appended content
text.unfix() {
	local -A _=(
		[.help]='file'
		[.argc]=1
	)

	flag.parse "$@"

	local file=${_[1]}
	must.f "$file"

	text._unfix "$file"
}

# text.sh - Private functions

text._unfix() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	grep -qE '(BEGIN|END) FIX' "$file" || return 0
	must.w "$file"
	sed -i '/BEGIN FIX/,/END FIX/d' "$file"
}
