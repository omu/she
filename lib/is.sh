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
	has.command pveversion && uname -a | grep -q -i pve
}

# is.vagrant: Detect Vagrant
is.vagrant() {
	# shellcheck disable=2119
	is.virtual || return 1

	[[ -d /vagrant ]] || id -u vagrant 2>/dev/null
}

is.mime() {
	local file=${1?${FUNCNAME[0]}: missing argument};     shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	local actual; actual=$(which.mime "$file")

	[[ $actual = "$expected" ]]
}

is.mimez() {
	local file=${1?${FUNCNAME[0]}: missing argument};     shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	local actual; actual=$(which.zmime "$file")

	[[ $actual = "$expected" ]]
}

declare -grA _file_type=(
	[gzip]=application/gzip
	[gz]=application/gzip
	[xz]=application/x-xz
	[bzip2]=application/bzip2
	[bz2]=application/bzip2
	[zip]=application/zip
	[tar]=application/tar
)

is.file._binary() {
	[[ $(file --mime-encoding --brief "$1") = binary ]]
}

is.file._program() {
	if is.file.binary "$1"; then
		[[ $(file --mime-type --brief "$1") =~ -executable$ ]]
	else
		has.file.shebang "$1"
	fi
}

is.file._compressed() {
	local mime; mime=$(file --mime-type --brief "$1"); mime=${mime#*/}

	case $mime in
	gzip|zip|x-xz|x-bz2) return 0 ;;
	*)                   return 1 ;;
	esac
}

is.file._tgz() {
	is.mime "$1" gzip && is.zmime "$1" tar
}

is.file._txz() {
	is.mime "$1" xz && is.zmime "$1" tar
}

is.file._tbz2() {
	is.mime "$1" bzip2 && is.zmime "$1" tar
}

is.file() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local type=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	if has.function is.file._"$type"; then
		is.file._"$type" "$file"
	elif [[ -n ${_file_type[$type]:-} ]]; then
		local mime=${_file_type[$type]}

		is.mime "$file" "$mime"
	else
		die "Unrecognized file type: $type"
	fi
}
