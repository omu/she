deb.add_key() {
	local artifact=

	if [[ ! -d $HOME/.gnupg ]]; then
		artifact=$HOME/.gnupg

		mkdir "$artifact" && chmod 700 "$artifact"
	fi

	local err
	deb.add_key_ "$@"  || err=$? && err=$?

	[[ -z ${artifact:-} ]] || rm -rf "$artifact"

	return "$err"
}

deb.update() {
	if .expired 60 /var/cache/apt/pkgcache.bin; then
		.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

		.getting 'Updating package index' apt-get update -y
	fi
}

deb.install() {
	[[ $# -gt 0 ]] || return 0

	deb.update

	.getting 'Installing packages' apt-get install --yes --no-install-recommends "$@"
}

deb.installed() {
	local package="${1?${FUNCNAME[0]}: missing argument}"; shift

	[[ -n "$(dpkg-query -W -f='${Installed-Size}' "$package" 2>/dev/null ||:)" ]]
}

deb.install_manual() {
	[[ $# -gt 0 ]] || return 0

	deb.update

	local url

	for url; do
		local deb

		file.download "$url" deb

		dpkg-deb --info "$deb" &>/dev/null || .die "Not a valid Debian package: $url"
		dpkg -i -- "$deb" 2>/dev/null || true
		apt-get -y install --no-install-recommends --fix-broken

		rm -f -- "$deb"
	done
}

deb.dist_added() {
	local dist=${1?${FUNCNAME[0]}: missing argument}; shift

	grep -qE "^deb.*\bdebian.org\b.*\b$dist\b" /etc/apt/*.list /etc/apt/sources.list.d/*.list
}

deb.dist_valid() {
	local dist=${1?${FUNCNAME[0]}: missing argument}; shift

	http.is http://ftp.debian.org/debian/dists/"$dist"/ OK
}

deb.missings() {
	local -n deb_missings_=${1?${FUNCNAME[0]}: missing argument}; shift

	local package
	for package; do
		# shellcheck disable=2016
		deb.installed "$package" || deb_missings_+=("$package")
	done
}

deb.uninstall() {
	[[ $# -gt 0 ]] || return 0

	local -a packages=()

	deb.missings packages "$@"
	[[ ${#packages[@]} -gt 0 ]] || return 0

	.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

	apt-get purge -y "${packages[@]}"

	.should -- apt-get autoremove -y
	.should -- apt-get autoclean -y
}

# deb - Private functions

deb.add_key_() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	local temp_file
	temp.file temp_file

	http.get "$url" >"$temp_file" || .die "Couldn't get key file: $url"

	local -a questioned_fingerprints installed_fingerprints

	mapfile -t questioned_fingerprints < <(
		gpg -nq --import --import-options import-show --with-colons "$temp_file" |
		awk -F: '$1 == "fpr" { print $10 }' 2>/dev/null
	)

	# shellcheck disable=2034
	mapfile -t installed_fingerprints < <(
		apt-key adv --list-public-keys --with-fingerprint --with-colon |
		awk -F: '$1 == "fpr" { print $10 }' 2>/dev/null
	)

	local fingerprint unfound
	for fingerprint in "${questioned_fingerprints[@]}"; do
		if ! .contains "$fingerprint" "${installed_fingerprints[@]}"; then
			unfound=$fingerprint
			break
		fi
	done

	if [[ -n ${unfound:-} ]]; then
		.running 'Adding APT key'
		apt-key add "$temp_file"
	fi

	temp.clean temp_file
}
