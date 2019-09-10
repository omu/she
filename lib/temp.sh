# Functions involving temporary directories or files

temp.file() {
	# shellcheck disable=2155
	local -n variable_=$(meta.public "$1")

	ensured _TMP_DIR

	local file_

	file_=$(mktemp -p "$_TMP_DIR" "$PROGNAME".XXXXXXXX) || die 'Fatal error: mktemp'
	at_exit_files "$file_"

	# shellcheck disable=2034
	variable_=$file_
}

temp.dir() {
	# shellcheck disable=2155
	local -n variable_=$(meta.public "$1")

	ensured _TMP_DIR

	local dir_
	dir_=$(mktemp -p "$_TMP_DIR" -d "$PROGNAME".XXXXXXXX) || die 'Fatal error: mktemp'
	at_exit_files "$dir_"

	# shellcheck disable=2034
	variable_=$dir_
}

# temp.inside: Execute command in temp dir and (optionally) move it elsewhere
temp.inside() {
	local outdir='' parents=''
	while [[ $# -gt 0 ]]; do
		case $1 in
		-outside|-out|-o|--outside|--out)
			[[ $# -gt 1 ]] || die "Argument required for flag: $1"
			shift

			outdir=$1
			shift
			;;
		-p|-parents|--parents)
			parents=true
			shift
			;;
		-*)
			die "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac
	done

	meta.narg 1 - "$@"

	if [[ -z $parents ]]; then
		[[ -d $outdir ]] || die "Outside directory must exist: $outdir"
		[[ -w $outdir ]] || die "Outside directory must be writable: $outdir"
	else
		[[ -n $outdir ]] || die 'No outside directory specified'
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
