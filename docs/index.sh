#!/usr/bin/env bash
# vim: ft=sh

set -Eeuo pipefail; shopt -s nullglob; [[ -z ${TRACE:-} ]] || set -x; unset CDPATH

TMPDIR=${TMPDIR:-/tmp}
SHEURL=${SHEURL:-https://raw.githubusercontent.com/omu/she/master/she}

cry() {
	echo >&2 "$@"
}

die() {
	cry "$@"
	exit 1
}

cleanup() {
	local tmpdir=$1
	local err=${2:-0}

	rm -rf -- "$tmpdir"

	return "$err"
}

init() {
	local tmpdir

	local mktemp
	for mktemp in /bin/mktemp /usr/bin/mktemp; do
		if [[ -x $mktemp ]]; then
			break
		fi
		unset mktemp
	done
	# As a security measure refuse to proceed if mktemp is not available.
	[[ -n $mktemp ]] || die "$mktemp is not available"

	tmpdir=$("$mktemp" -d -t she.XXXXXXXX) || die "$mktemp returned error"
	trap 'cleanup "'"$tmpdir"'" $?' EXIT HUP INT QUIT TERM

	pushd "$tmpdir" >/dev/null

	if command -v curl >/dev/null; then
		curl -fsSL "$SHEURL" >she 2>&1 || curl -fSL "$SHEURL" >she || die "Couldn't download she with curl(1)."
	elif command -v wget >/dev/null; then
		local hsts_unfound_before=
		[[ -f ~/.wget-hsts ]] || hsts_unfound_before=true
		wget -q "$SHEURL" >/dev/null 2>&1 || wget "$SHEURL" || die "Couldn't download she with wget(1)."
		if [[ -f ~/.wget-hsts ]] && [[ -n $hsts_unfound_before ]]; then
			rm -f ~/.wget-hsts
		fi
	else
		die "Wget or Curl required"
	fi

	[[ -f she ]] || die "Couldn't download she.  Make TRACE=true and retry for details."

	chmod +x she
	export PATH="$PWD:$PATH"
	popd >/dev/null
}

main.source() {
	init
	eval -- "$(she src "$@")"
}

main.execute() {
	init

	local -a args=("$@")

	set -- ""
	eval -- "$(she src)"

	"${args[@]}"
}
