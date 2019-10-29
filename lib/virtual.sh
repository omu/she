# virtual.sh - Virtualization functions

# Detect virtualization type
virtual.what() {
	local -A _=(
		[.argc]=0
	)

	flag.parse

	systemd-detect-virt || true
}

# Assert virtualization type
virtual.is() {
	local -A _=(
		[.help]='[VIRTUALIZATION]'
		[.argc]=0-
	)

	flag.parse

	if [[ $# -gt 0 ]]; then
		local virtual=$1

		local func=virtual.is._"${virtual}"

		if .callable "$func"; then
			"$func"
		else
			[[ $(virtual.what) = "$virtual" ]]
		fi
	else
		[[ -z ${CI:-} ]] || return 0
		[[ -z ${PACKER_BUILDER_TYPE:-} ]] || return 0

		systemd-detect-virt -q
	fi
}

# Assert any of the virtualization type
virtual.any() {
	local -A _=(
		[.help]='VIRTUALIZATION...'
		[.argc]=1-
	)

	flag.parse

	local virtual

	for virtual; do
		local func=virtual.is._"${virtual}"

		if .callable "$func"; then
			"$func"
		else
			[[ $(virtual.what) = "$virtual" ]]
		fi || continue

		return 0
	done

	return 1
}

# os - Private functions

virtual.is._vagrant() {
	os.is._virtual || return 1

	[[ -d /vagrant ]] || id -u vagrant 2>/dev/null
}

virtual.is._physical() {
	! systemd-detect-virt -q
}
