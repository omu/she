#!/usr/bin/env bats

load test_helper

@test "Implicit https schema" {
	she <<-'EOF'
		cmd.from
		from.parse url github.com/owner/repo/a/b
		echo "${url[protocol]}"
		echo "${url[path]}"
		echo "${url[slug]}"
	EOF
	[[ $status -eq 0 ]]
	[[ ${lines[0]} == https ]]
	[[ ${lines[1]} == github.com/owner/repo ]]
	[[ ${lines[2]} == a/b ]]
}

@test "Absolute file schema" {
	she <<-'EOF'
		cmd.from
		from.parse url /a/b/c
		echo "${url[protocol]}"
		echo "${url[path]}"
	EOF
	[[ $status -eq 0 ]]
	[[ ${lines[0]} == file ]]
	[[ ${lines[1]} == /a/b/c ]]
}

@test "Relative file schema" {
	she <<-'EOF'
		cmd.from
		from.parse url ./a/b/c
		echo "${url[protocol]}"
		echo "${url[path]}"
	EOF
	[[ $status -eq 0 ]]
	[[ ${lines[0]} == file ]]
	[[ ${lines[1]} == $PWD/a/b/c ]]
}

@test "Missing owner" {
	she 2>&1 <<-'EOF'
		cmd.from
		from.parse url github.com
	EOF
	[[ $status -eq 1 ]]
	[[ $output =~ owner ]]
}

@test "Unsupported provider" {
	she 2>&1 <<-'EOF'
		cmd.from
		from.parse url launchpad.net
	EOF
	[[ $status -eq 1 ]]
	[[ $output =~ provider ]]
}
