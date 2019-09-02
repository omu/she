tempdir.make() {
	# shellcheck disable=2178,2155
	local -n tempdir_=$(meta.public "$1")

	tempdir_=$(mktemp -d "$PROGNAME".XXXXXXXX) || ui.die "Fatal error: mktemp"

	# shellcheck disable=2154
	trap '
		err=$?
		rm -rf -- "$tempdir_"
		exit $err
	' EXIT HUP INT QUIT TERM
}

tempdir.inside() {
	local outdir=$1
	shift

	file.moveable "$outdir" "$tempdir"

	local tempdir
	tempdir.make tempdir

	local here=$PWD

	must cd "$tempdir"
	"$@"
	must cd "$here"

	file.move "$outdir" "$tempdir"
}
