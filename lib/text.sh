# text.sh - Text blob manipulations

text.fix() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local mark=${1:-_}

	.must 'Input from stdin required' .piped
	.must "No such file: $file" [[ -f "$file" ]]

	text.unfix "$file" "$mark"

	{
		echo "# begin $mark"
		cat
		echo "# END $mark"
	} >>"$file"
}

text.unfix() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local mark=${1:-_}

	.must "No such file: $file" [[ -f "$file" ]]

	grep -qE "#\s+(begin|end)\s+$mark" "$file" || return 0
	.must "No such file or file is not writable: $file" [[ -w "$file" ]]
	sed -i "/begin $mark/,/end $mark/d" "$file"
}
