#!/bin/bash

# shellcheck disable=1090
. <(t) ../../bin/_

string='foo/bar/'

t ok string.has_suffix_deleted string / -- string.has_suffix_deleted works

test:hmm() {
	t is 'foo/bar' "$string" -- string has no suffix
}

t ok [[ ok = ok ]] -- ok is ok

t go
