# Debian package management

# deb.update: Update Debian package index
deb.update() {
	[[ -n $(find /var/cache/apt/pkgcache.bin -mmin -60 2>/dev/null) ]] || apt-get update
}

# deb.install: Install Debian packages
deb.install() {
	deb.update

	[[ $# -eq 0 ]] || apt-get -y install --no-install-recommends "$@"
}
