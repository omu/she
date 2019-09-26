# deb.sh - Debian package management

export DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# deb.install: Install Debian packages
deb.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefer]=
		[-missings]=false
	)

	flag.parse "$@"
	flag.must 1

	local prefer=${_[-prefer]:-}

	case $prefer in
	backports)
		if is.debian stable; then
			local codename
			codename=$(which.debian codename)

			deb.repository backports <<-EOF
				deb http://ftp.debian.org/debian $codename-backports main contrib non-free
			EOF
		fi
		;;
	experimental)
		if is.debian unstable; then
			deb.repository experimental <<-EOF
				deb http://ftp.debian.org/debian experimental main contrib non-free
			EOF
		fi
		;;
	*)
		die "Unrecognized prefered repository: $prefer"
	esac

	deb.update

	local -a packages=("$@")

	flag.false missings || deb.missings packages "$@"

	apt-get -y install --no-install-recommends "${packages[@]}"
}

# deb.update: Update Debian package index
deb.update() {
	expired 60 /var/cache/apt/pkgcache.bin || apt-get update
}

# deb.repository: Add Debian repository
deb.repository() {
	local name=${1?missing argument: name}
	shift

	local keyurl=${1?missing argument: keyurl}
	shift

	cat >/etc/apt/sources.list.d/"$name".list
	[[ -z ${keyurl:-} ]] || http.get -fsSL "$keyurl" | apt-key add -

	apt-get update -y
}

deb.missings() {
	:
}
