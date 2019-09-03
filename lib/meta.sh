# Meta functions

meta.public() {
	if [[ $1 =~ (^_|_$) ]]; then
		bug "Not a simple name: $1"
	else
		echo "$1"
	fi
}
