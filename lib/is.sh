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

	[[ $actual = "$expected" ]] || [[ $actual =~ -$expected$ ]]
}

is.mimez() {
	local file=${1?${FUNCNAME[0]}: missing argument};     shift
	local expected=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	: # TODO
}

# is.file.binary: Detect binary file
is.file.binary() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	[[ $(file --mime-encoding --brief "$file") = binary ]]
}

is.file.program() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	if is.file.binary "$file"; then
		[[ $(file --mime-type --brief "$file") =~ -executable$ ]]
	else
		has.file.shebang "$file"
	fi
}

is.file.compressed() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	local mime; mime=$(file --mime-type --brief "$file"); mime=${mime#*/}

	case $mime in
	gzip|zip|x-xz|x-bz2) return 0 ;;
	*)                   return 1 ;;
	esac
}

is.file.tgz() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	is.mime "$file" gzip && is.zmime "$file" tar
}

is.file.txz() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	is.mime "$file" x-xz && is.zmime "$file" tar
}

is.file.tbz2() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	is.mime "$file" bzip2 && is.zmime "$file" tar
}

is.file.zip() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	is.mime "$file" zip
}

is.file.gz() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	is.mime "$file" gzip
}

is.file.bz2() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	is.mime "$file" bzip2
}

is.file.xz() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	is.mime "$file" x-xz
}
