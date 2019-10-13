#!/bin/bash

# shellcheck disable=1090
. <(t) ../../bin/_

# test:string.has_suffix_deleted() {
# 	local string='foo/bar/'
#
# 	t ok string.has_suffix_deleted string /
#
# 	t is 'foo/bar' "$string"
# }
#
# t end

string='foo/bar/'

t ok 'string.has_suffix_deleted works' string.has_suffix_deleted string /

t is 'string has no suffix' 'foo/bar' "$string"

t end
