# os.sh - OS related functions

# os.virtual: Virtualization type
# shellcheck disable=2120
os.virtual() {
	local -A _=(
		[.argc]=0-
	)

	flag.parse "$@"

	systemd-detect-virt || true
}

# os.dist: Distribution name
# shellcheck disable=2120
os.dist() {
	local -A _=([.argc]=0); flag.parse "$@"

	# shellcheck disable=1091
	(unset ID && . /etc/os-release 2>/dev/null && echo "$ID")
}

# os.codename: Distribution codename
# shellcheck disable=2120
os.codename() {
	local -A _=([.argc]=0); flag.parse "$@"

	lsb_release -sc
}

# os.is: Detect OS feature
os.is() {
	local -A _=(
		[.help]='feature'
		[.argc]=1-
	)

	flag.parse "$@"

	local feature=${_[1]}

	local func=os.is._"${feature}"

	must.callable "$func" "Unable to detect: $feature"

	local -a args; flag.args args

	"$func" "${args[@]:1}"
}

# os.sh - Private functions

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
		[[ "$(os.distribution)" = 'debian' ]]
	fi
}

os.is._ubuntu() {
	if [[ $# -gt 0 ]]; then
		[[ "$(os.codename)" = "$1" ]]
	else
		[[ "$(os.distribution)" = 'ubuntu' ]]
	fi
}

os.is._proxmox() {
	available pveversion && uname -a | grep -q -i pve
}

os.is._vagrant() {
	# shellcheck disable=2119
	os.is._virtual || return 1

	[[ -d /vagrant ]] || id -u vagrant 2>/dev/null
}

os.is._physical() {
	! systemd-detect-virt -q
}
