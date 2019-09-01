# Meta functions

meta.public_name() {
	if [[ $1 =~ (^_|_$) ]]; then
		ui.bug "BUG: Not a simple name: $1: "
		exit 1
	else
		echo "$1"
	fi
}
