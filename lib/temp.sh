# Functions involving temporary directories or files

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
	local outdir='' parents=''
	while [[ $# -gt 0 ]]; do
		case $1 in
		-o|-out|-outside|--out|--outside)
			[[ $# -gt 1 ]] || ui.die "Argument required for flag: $1"
			shift

			outdir=$1
			shift
			;;
		-p|-parents|--parents)
			parents=true
			shift
			;;
		-*)
			ui.die "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac
	done

	if [[ -n $parents ]]; then
		[[ -n $outdir ]] || ui.die 'No outside directory specified'
	else
		[[ -d $outdir ]] || ui.die "Outside directory must exist: $outdir"
		[[ -w $outdir ]] || ui.die "Outside directory must be writable: $outdir"
	fi

	local origdir=$PWD

	local tempdir
	temp.dir tempdir

	must cd "$tempdir"
	"$@"
	must cd "$origdir"

	if [[ -n $outdir  ]]; then
		[[ -z $parents ]] || must mkdir -p "$outdir"
		cp -aT "$tempdir" "$outdir"
	fi

	rm -rf -- "$tempdir"
}
