# text.sh - Text blob manipulations

# Append stdin content to the target file
text.fix() {
	local -A _=(
		[.help]='FILE'
		[.argc]=1
	)

	flag.parse

	local file=$1; must.f "$file"

	text._unfix "$file"

	{
		echo '# BEGIN FIX'
		cat
		echo '# END FIX'
	} >>"$file"
}

# Remove appended content
text.unfix() {
	local -A _=(
		[.help]='FILE'
		[.argc]=1
	)

	flag.parse

	local file=$1; must.f "$file"

	text._unfix "$file"
}

# text - Private functions

text._unfix() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	grep -qE '(BEGIN|END) FIX' "$file" || return 0
	must.w "$file"
	sed -i '/BEGIN FIX/,/END FIX/d' "$file"
}
