#!/bin/bash

# shellcheck disable=1090
. <(t)

test.string.has_prefix_deleted() {
	local string='foo/bar/'

	t ok string.has_prefix_deleted string /
	t is "$string" 'foo/bar'
}

t run