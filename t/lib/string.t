#!/bin/bash

# shellcheck disable=1090
. <(t)

test:string.has_suffix_deleted() {
	local string='foo/bar/'

	t ok string.has_suffix_deleted string /

	t is 'foo/bar' "$string"
}

t end
