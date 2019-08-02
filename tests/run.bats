#!/usr/bin/env bats

load test_helper

@test "Must run without tests" {
	there=file://$(remote)
	she <<-EOF
		cmd.from
		main.from "$there"
	EOF
	[[ $status -eq 0 ]]
	pushd "$output"
	she <<-EOF
		cmd.run
		main.run foo
	EOF
	[[ $status -eq 0 ]]
	[[ "${lines[1]}" == 'run foo'  ]]
}

@test "Must run with tests" {
	there=file://$(remote)
	she <<-EOF
		cmd.from
		main.from "$there"
	EOF
	[[ $status -eq 0 ]]
	pushd "$output"
	she <<-EOF
		cmd.try
		main.try foo
	EOF
	[[ $status -eq 0 ]]
	[[ "${lines[1]}" == 'run foo'  ]]
	[[ "${lines[3]}" == 'test foo' ]]
}

@test "Must accept variables" {
	there=file://$(remote)
	she <<-EOF
		cmd.from
		main.from "$there"
	EOF
	[[ $status -eq 0 ]]
	pushd "$output"
	she var='xxx yyy' <<-EOF
		cmd.run
		main.run foo
	EOF
	[[ $status -eq 0 ]]
	[[ "${lines[1]}" == 'run foo' ]]
	[[ "${lines[2]}" == 'xxx yyy' ]]
}
