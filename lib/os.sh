# os.sh - OS related functions

# os.virtual: Which virtualization
os.virtual() {
	systemd-detect-virt || true
}

# os.distribution: Which distribution
os.distribution() {
	# shellcheck disable=1091
	(unset ID && . /etc/os-release 2>/dev/null && echo "$ID")
}

# os.codename: Which distribution release
os.codename() {
	lsb_release -sc
}

# os.is: Detect OS feature
os.is() {
	local feature=${1?${FUNCNAME[0]}: missing argument}; shift

	local func=os.is._"${feature}"

	must.callable "$func" "Unable to detect: $feature"

	"$func"
}

# is.virtual: Detect given virtualization
# shellcheck disable=2120
os.is._virtual() {
	if [[ $# -gt 0 ]]; then
		[[ "$(os.virtual)" = "$1" ]]
	else
		[[ -z ${CI:-} ]] || return 0
		[[ -z ${PACKER_BUILDER_TYPE:-} ]] || return 0

		systemd-detect-virt -q
	fi
}

# is.debian: Detect Debian or its given release
os.is._debian() {
	if [[ $# -gt 0 ]]; then
		case $1 in
		unstable|testing|sid)
			grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
			;;
		stable)
			! grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
			;;
		*)
			[[ "$(os.codename)" = "$1" ]]
			;;
		esac
	else
		[[ "$(os.distribution)" = 'debian' ]]
	fi
}

# is.ubuntu: Detect Ubuntu or its given release
os.is._ubuntu() {
	if [[ $# -gt 0 ]]; then
		[[ "$(os.codename)" = "$1" ]]
	else
		[[ "$(os.distribution)" = 'ubuntu' ]]
	fi
}

# is.proxmox: Detect Proxmox
os.is._proxmox() {
	available pveversion && uname -a | grep -q -i pve
}

# is.vagrant: Detect Vagrant
os.is._vagrant() {
	# shellcheck disable=2119
	os.is._virtual || return 1

	[[ -d /vagrant ]] || id -u vagrant 2>/dev/null
}
