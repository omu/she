# cmd/virt - Virtualization commands

# Assert any of the virtualization types
virt:any() {
	local -A _=(
		[.help]='VIRTUALIZATION...'
		[.argc]=1-
	)

	flag.parse

	virt.any "$@"
}

# Assert virtualization type
virt:is() {
	local -A _=(
		[.help]='VIRTUALIZATION'
		[.argc]=1
	)

	flag.parse

	virt.is "$@"
}

# Detect virtualization type
virt:which() {
	local -A _=(
		[.argc]=0
	)

	flag.parse

	virt.which
}
