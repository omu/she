#!/usr/bin/env bats

load test_helper

@test "etc without src output" {
	export SHE_ETC=$PWD/var
	run "$SHE" etc site var1=val1 var2=val2
	[[ $status -eq 0 ]]
	[[ "${lines[0]}" == 'val1' ]]
	[[ "${lines[1]}" == 'val2' ]]

	run "$SHE" etc site
	[[ $status -eq 0 ]]
	[[ "${lines[0]}" == 'val1' ]]
	[[ "${lines[1]}" == 'val2' ]]
}

@test "etc with src output" {
	export SHE_ETC=$PWD/var
	run "$SHE" etc -src site var1=val1 var2=val2
	[[ $status -eq 0 ]]
	[[ "${lines[0]}" == '('                ]]
	[[ "${lines[1]}" == "	[var1]='val1'" ]]
	[[ "${lines[2]}" == "	[var2]='val2'" ]]
	[[ "${lines[3]}" == ')'                ]]

	run "$SHE" etc -src site
	[[ $status -eq 0 ]]
	[[ "${lines[0]}" == '('                ]]
	[[ "${lines[1]}" == "	[var1]='val1'" ]]
	[[ "${lines[2]}" == "	[var2]='val2'" ]]
	[[ "${lines[3]}" == ')'                ]]
}
