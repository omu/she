#!/usr/bin/env bats

load test_helper

@test "Must get through implicit https schema" {
	there=github.com/github/gitignore
	she <<-EOF
		cmd.from
		main.from "$there"
	EOF
	[[ $status -eq 0 ]]

	pushd "$output"
	run git config --get remote.origin.url 2>&1
	[[ $status -eq 0 ]]
	[[ "$output" == "https://$there" ]]
}

@test "Must get through explicit https schema" {
	skip
	there=https://github.com/github/gitignore
	she <<-EOF
		cmd.from
		main.from "$there"
	EOF
	[[ $status -eq 0 ]]

	pushd "$output"
	run git config --get remote.origin.url
	[[ $status -eq 0 ]]
	[[ "$output" == "$there" ]]
}


@test "Must get through git schema" {
	skip
	there=https://github.com/github/gitignore
	she <<-EOF
		cmd.from
		main.from "$there"
	EOF
	[[ $status -eq 0 ]]

	pushd "$output"
	run git config --get remote.origin.url
	[[ $status -eq 0 ]]
	[[ "$output" == "$there" ]]
}

@test "Must get through file schema" {
	there=file://$(remote)
	she <<-EOF
		cmd.from
		main.from "$there"
	EOF
	[[ $status -eq 0 ]]
	[[ "$output" == "$(remote)" ]]
}

@test "Must respond to FROM_TO" {
	there=file://$(remote)
	she FROM_TO=$HOME <<-EOF
		cmd.from
		main.from "$there"
	EOF
	[[ $status -eq 0 ]]
	[[ "$output" == "$HOME" ]]
}
