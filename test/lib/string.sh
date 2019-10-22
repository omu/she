#!/bin/bash

# shellcheck disable=1090
. <(t) ../../bin/_ ../t

string='foo/bar/'

t ok string.has_suffix_deleted string / -- string.has_suffix_deleted works

test:hmm() {
	t like "$string" '^foo/bar$' -- string has no suffix
}

t ok [[ ok = ok ]] -- ok is ok

t out true -- command must be silent

t out echo -e "foo\nbar" -- command must match <<'EOF'
	foo
	bar
EOF

t go
