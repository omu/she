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

# is.file: Detect file type
is.file() {
	local -A _

	is.file_ "$@"
}

# is.function: Detect function
is.function() {
	local name=${1?${FUNCNAME[0]}: missing argument}; shift

	[[ $(type -t "$name" || true) == function ]]
}

is.file_() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift
	local type=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	local func=is.file._"${expected}"_

	must.func "$func" "Unable to know type: $type"

	"$func" "$file"
}

is.file._program_() {
	local mime encoding

	IFS='; ' read -r mime encoding < <(file --mime --brief "$1")

	if [[ $encoding =~ binary$ ]]; then
		if [[ $mime  =~ -executable$ ]]; then
			_[file.program]=binary
			return 0
		fi
	else
		if head -n 1 "$file" | grep -q '^#!'; then
			_[file.program]=script
			return 1
		fi
	fi

	return 1
}

is.file._compressed_() {
	local mime; mime=$(file --mime-type --brief "$1")

	case $mime in
	gzip|zip|x-xz|x-bzip2|x-zstd)
		local zip=$mime; zip=${zip##*/}; zip=${zip##*-}

		if [[ $(file --mime-type --brief --uncompress-noreport "$file") = tar ]]; then
			_[file.zip]=tar.$zip
		else
			_[file.zip]=$zip
		fi

		return 0 ;;
	*)
		return 1 ;;
	esac
}