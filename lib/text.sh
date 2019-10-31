# text.sh - Text blob manipulations

# Append stdin content to the target file
text.fix() {
	.must 'Input from stdin required' .piped

	local -A _=(
		[.help]='FILE [SIGNATURE]'
		[.argc]=1-
	)

	flag.parse

	local file=$1 signature=${2:-fix}

	.must "No such file: $file" [[ -f "$file" ]]

	text._unfix "$file" "$signature"

	{
		echo "# begin $signature"
		cat
		echo "# END $signature"
	} >>"$file"
}

# Remove appended content
text.unfix() {
	local -A _=(
		[.help]='FILE [SIGNATURE]'
		[.argc]=1-
	)

	flag.parse

	local file=$1 signature=${2:-fix}

	.must "No such file: $file" [[ -f "$file" ]]

	text._unfix "$file" "$signature"
}

# text - Private functions

text._unfix() {
	local file=${1?${FUNCNAME[0]}: missing argument};      shift
	local signature=${1?${FUNCNAME[0]}: missing argument}; shift

	grep -qE "#\s+(begin|end)\s+$signature" "$file" || return 0
	.must "No such file or file is not writable: $file" [[ -w "$file" ]]
	sed -i "/begin $signature/,/end $signature/d" "$file"
}
