#!/bin/bash

# shellcheck disable=1090
. <(t) ../t

string='foo/bar/'

t ok string.has_suffix_deleted string / -- string.has_suffix_deleted works

test.startup() {
	:
}

test.shutdown() {
	:
}

test.setup() {
	:
}

test.teardown() {
	:
}

test.hmm() {
	t like "$string" '^foo/bar$' -- string has no suffix
}

t ok [[ ok = ok ]] -- SKIP ok is ok

t out true -- TODO command must be silent

t out echo -e "foo\nbar" -- command must match <<'EOF'
	foo
	bar
EOF

t go
