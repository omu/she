# os.sh - OS related functions

# Virtualization type
# shellcheck disable=2120
os.virtual() {
	local -A _=(
		[.argc]=0-
	)

	flag.parse

	systemd-detect-virt || true
}

# Distribution name
# shellcheck disable=2120
os.dist() {
	local -A _; flag.parse

	# shellcheck disable=1091
	(unset ID && . /etc/os-release 2>/dev/null && echo "$ID")
}

# Distribution codename
# shellcheck disable=2120
os.codename() {
	local -A _; flag.parse

	lsb_release -sc
}

# Detect OS feature
os.is() {
	local -A _=(
		[.help]='FEATURE'
		[.argc]=1-
	)

	flag.parse

	local feature=$1
	shift

	local func=os.is._"${feature}"

	.must "Unable to detect: $feature" .callable "$func"

	"$func" "$@"
}

# os - Private functions

# shellcheck disable=2120
os.is._virtual() {
	if [[ $# -gt 0 ]]; then
		[[ $(os.virtual) = "$1" ]]
	else
		[[ -z ${CI:-} ]] || return 0
		[[ -z ${PACKER_BUILDER_TYPE:-} ]] || return 0

		systemd-detect-virt -q
	fi
}

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
		[[ "$(os.dist)" = 'debian' ]]
	fi
}

os.is._ubuntu() {
	if [[ $# -gt 0 ]]; then
		[[ "$(os.codename)" = "$1" ]]
	else
		[[ "$(os.dist)" = 'ubuntu' ]]
	fi
}

os.is._proxmox() {
	.available pveversion && uname -a | grep -q -i pve
}

os.is._vagrant() {
	os.is._virtual || return 1

	[[ -d /vagrant ]] || id -u vagrant 2>/dev/null
}

os.is._physical() {
	! systemd-detect-virt -q
}
