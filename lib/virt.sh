# virt.sh - Virtualization functions

virt.any() {
	local virt

	for virt; do
		local func=virt.is."${virt}"

		if .callable "$func"; then
			"$func"
		else
			[[ $(virt.which) = "$virt" ]]
		fi || continue

		return 0
	done

	return 1
}

virt.is() {
	local virt=${1?${FUNCNAME[0]}: missing argument}; shift

	local func=virt.is."${virt}"

	if .callable "$func"; then
		"$func"
	else
		[[ $(virt.which) = "$virt" ]]
	fi
}

virt.which() {
	systemd-detect-virt || true
}

virt.is.any() {
	[[ -z ${CI:-} ]] || return 0
	[[ -z ${PACKER_BUILDER_TYPE:-} ]] || return 0

	systemd-detect-virt -q
}

virt.is.vagrant() {
	virt.is.any || return 1

	[[ -d /vagrant ]] || id -u vagrant 2>/dev/null
}

virt.is.physical() {
	! systemd-detect-virt -q
}

virt.is.physical() {
	! systemd-detect-virt -q
}
