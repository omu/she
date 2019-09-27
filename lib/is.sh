# is.sh - Predications at is form

# is.virtual: Detect given virtualization
# shellcheck disable=2120
is.virtual() {
	if [[ $# -gt 0 ]]; then
		[[ "$(which.virtual)" = "$1" ]]
	else
		[[ -z ${CI:-} ]] || return 0
		[[ -z ${PACKER_BUILDER_TYPE:-} ]] || return 0

		is.docker && return 0

		systemd-detect-virt -q
	fi
}

# is.debian: Detect Debian or its given release
is.debian() {
	if [[ $# -gt 0 ]]; then
		case $1 in
		unstable|testing|sid)
			grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
			;;
		stable)
			! grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
			;;
		*)
			[[ "$(which.codename)" = "$1" ]]
			;;
		esac
	else
		[[ "$(which.distribution)" = 'debian' ]]
	fi
}

# is.ubuntu: Detect Ubuntu or its given release
is.ubuntu() {
	if [[ $# -gt 0 ]]; then
		[[ "$(which.codename)" = "$1" ]]
	else
		[[ "$(which.distribution)" = 'ubuntu' ]]
	fi
}

# is.proxmox: Detect Proxmox
is.proxmox() {
	command -v pveversion >/dev/null && uname -a | grep -q -i pve
}

# is.vagrant: Detect Vagrant
is.vagrant() {
	# shellcheck disable=2119
	is.virtual || return 1

	[[ -d /vagrant ]] || id -u vagrant 2>/dev/null
}
