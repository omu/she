# deb.sh - Debian package management

export DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# deb.update: Update Debian package index
deb.update() {
	expired 60 /var/cache/apt/pkgcache.bin || apt-get update
}

# deb.install: Install Debian packages
deb.install() {
	deb.update

	[[ $# -eq 0 ]] || apt-get -y install --no-install-recommends "$@"
}
