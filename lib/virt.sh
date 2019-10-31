# virt.sh - Virtualization functions

# Assert any of the virtualization types
virt.any() {
	local -A _=(
		[.help]='VIRTUALIZATION...'
		[.argc]=1-
	)

	flag.parse

	local virt
	for virt; do
		local func=virt.is._"${virt}"

		if .callable "$func"; then
			"$func"
		else
			[[ $(virt.which) = "$virt" ]]
		fi || continue

		return 0
	done

	return 1
}

# Assert virtualization type
virt.is() {
	local -A _=(
		[.help]='VIRTUALIZATION'
		[.argc]=1
	)

	flag.parse

	local virt=$1

	local func=virt.is._"${virt}"

	if .callable "$func"; then
		"$func"
	else
		[[ $(virt.which) = "$virt" ]]
	fi
}

# Detect virtualization type
virt.which() {
	local -A _=(
		[.argc]=0
	)

	flag.parse

	systemd-detect-virt || true
}

# virt - Private functions

virt.is._any() {
	[[ -z ${CI:-} ]] || return 0
	[[ -z ${PACKER_BUILDER_TYPE:-} ]] || return 0

	systemd-detect-virt -q
}

virt.is._vagrant() {
	virt.is._any || return 1

	[[ -d /vagrant ]] || id -u vagrant 2>/dev/null
}

virt.is._physical() {
	! systemd-detect-virt -q
}
