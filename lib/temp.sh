temp.file() {
	# shellcheck disable=2155
	local -n variable_=$(meta.public "$1")

	local file_

	file_=$(mktemp "$PROGNAME".XXXXXXXX) || abort 'Fatal error: mktemp'
	at_exit_files "$file_"

	# shellcheck disable=2034
	variable_=$file_
}

temp.dir() {
	# shellcheck disable=2155
	local -n variable_=$(meta.public "$1")

	local dir_

	dir_=$(mktemp -d "$PROGNAME".XXXXXXXX) || abort 'Fatal error: mktemp'
	at_exit_files "$dir_"

	# shellcheck disable=2034
	variable_=$dir_
}

# temp.inside: Execute command in temp dir and (optionally) move it elsewhere
temp.inside() {
	local outdir=
	while [[ $# -gt 0 ]]; do
		case $1 in
		-out|-outside|--out|--outside)
			[[ -n ${2:-} ]] || ui.die "Argument required for flag: $1"
			shift

			file.moveable "$1"
			outdir=$1
			shift

			break
			;;
		-*)
			ui.die "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac

		shift
	done

	local origdir=$PWD

	local tempdir
	temp.dir tempdir

	must cd "$tempdir"
	"$@"
	must cd "$origdir"

	[[ -z $outdir ]] || file.move "$tempdir" "$outdir"
}
