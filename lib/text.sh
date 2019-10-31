# text.sh - Text blob manipulations

# Append stdin content to the target file
text.fix() {
	.must 'Input from stdin required' .piped

	local -A _=(
		[.help]='FILE [MARK]'
		[.argc]=1-
	)

	flag.parse

	local file=$1 mark=${2:-_}

	.must "No such file: $file" [[ -f "$file" ]]

	text._unfix "$file" "$mark"

	{
		echo "# begin $mark"
		cat
		echo "# END $mark"
	} >>"$file"
}

# Remove appended content
text.unfix() {
	local -A _=(
		[.help]='FILE [MARK]'
		[.argc]=1-
	)

	flag.parse

	local file=$1 mark=${2:-_}

	.must "No such file: $file" [[ -f "$file" ]]

	text._unfix "$file" "$mark"
}

# text - Private functions

text._unfix() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local mark=${1?${FUNCNAME[0]}: missing argument}; shift

	grep -qE "#\s+(begin|end)\s+$mark" "$file" || return 0
	.must "No such file or file is not writable: $file" [[ -w "$file" ]]
	sed -i "/begin $mark/,/end $mark/d" "$file"
}
