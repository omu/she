#!/usr/bin/env bash

export SHE=$PWD/she
export FROM="$PWD/she from"
export RUN="$PWD/she run"

remote() { echo "$FROM_TMPDIR"/remote;    }

pushd()  { builtin pushd "$1" >/dev/null || exit; }
popd()   { builtin popd >/dev/null       || exit; }

setup() {
	FROM_TMPDIR=$(mktemp -d) || exit 1
	export FROM_TMPDIR

	mkdir -p "$(remote)"
	pushd "$(remote)" || exit $?

	cat >foo.sh <<-'EOF'
	#!/bin/bash
	echo run foo
	echo "$var"
	EOF
	cat >foo_test.sh <<-'EOF'
	#!/bin/bash
	echo test foo
	echo "$var"
	EOF
	{
		git init
		git config user.email "you@example.com"
		git config user.name "You"
		git add .
		git commit -a -m .
	} >/dev/null 2>&1

	popd || exit $?
}

teardown() {
	[[ -z $FROM_TMPDIR ]] || rm -rf "$FROM_TMPDIR"
}

she() {
	run env "$@" bash <<-EOF
		source "$SHE"
		$(cat -)
	EOF
}
