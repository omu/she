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

# is.file: Detect file type
is.file() {
	local -A is_file_=(
		[bz2]=application/x-bzip2
		[bzip2]=application/x-bzip2
		[gz]=application/gzip
		[gzip]=application/gzip
		[tar]=application/tar
		[xz]=application/x-xz
		[zip]=application/zip
		[zst]=application/x-zstd
		[zstd]=application/x-zstd
	)

	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local type=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	if has.function is.file._"$type"; then
		is.file._"$type" "$file"
	elif [[ -n ${is_file_[$type]:-} ]]; then
		local mime=${is_file_[$type]}

		is.mime "$file" "$mime"
	else
		die "Unrecognized file type: $type"
	fi
}

# is.mime: Detect mime type
is.mime() {
	local file=${1?${FUNCNAME[0]}: missing argument};     shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	local actual; actual=$(which.mime "$file")

	[[ $actual = "$expected" ]]
}

# is.zmime: Detect mime type inside a compressed file
is.mimez() {
	local file=${1?${FUNCNAME[0]}: missing argument};     shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	local actual; actual=$(which.zmime "$file")

	[[ $actual = "$expected" ]]
}

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
	local mime; mime=$(file --mime-type --brief "$1"); mime=${mime#application/}

	case $mime in
	gzip|zip|x-xz|x-bzip2|x-zstd) return 0 ;;
	*)                            return 1 ;;
	esac
}

is.file._tar.gz() {
	is.mime "$1" gzip && is.zmime "$1" tar
}

is.file._tar.xz() {
	is.mime "$1" xz && is.zmime "$1" tar
}

is.file._tar.bz2() {
	is.mime "$1" x-bzip2 && is.zmime "$1" tar
}

is.file._tar.zst() {
	is.mime "$1" x-zstd && is.zmime "$1" tar
}
