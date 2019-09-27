# deb.sh - Debian package management

export DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# deb.install: Install Debian packages
deb.install() {
	# shellcheck disable=2192
	local -A _=(
		[-prefer]=
		[-missings]=false
		[-clean]=false
	)

	local -a opts=(
		--yes
		--no-install-recommends
	)

	flag.parse "$@"

	local prefer=${_[-prefer]:-} target

	case $prefer in
	backports)
		local dist; dist=$(which.debian codename)-backports

		if is.debian stable && deb._dist_valid "$dist"; then
			deb._dist_added "$dist" || deb.repository "$dist" <<-EOF
				deb http://ftp.debian.org/debian $dist main contrib non-free
			EOF
			target=$dist
		fi
		;;
	experimental)
		local dist=experimental

		if is.debian unstable; then
			deb._dist_added "$dist" || deb.repository experimental <<-EOF
				deb http://ftp.debian.org/debian $dist main contrib non-free
			EOF
			target=$dist
		fi
		;;
	*)
		die "Unrecognized prefered repository: $prefer"
	esac

	[[ -z ${target:-} ]] || opts+=(
		--target-release
		"$target"
	)

	local -a packages

	if flag.true missings; then
		deb._missings packages "$@"
	else
		packages=("$@")
	fi

	[[ ${#packages[@]} -gt 0 ]] || return 0

	deb.update
	apt-get install "${opts[@]}" "${packages[@]}"
}

deb.uninstall() {
	local -a packages

	deb._missings packages "$@"
	[[ ${#packages[@]} -gt 0 ]] || return 0

	apt-get purge -y "${packages[@]}"

	might apt-get autoremove -y && might apt-get autoclean -y
}

deb.install_file() {
	local url
	for url; do
		local deb

		file.download "$url" deb
		dpkg -i -- "$deb" 2>/dev/null || true
		apt-get -y install --no-install-recommends --fix-broken
		rm -f -- "$deb"
	done
}

# deb.missings: Print missing packages among given packages
deb.missings() {
	local -a missings
	deb._missings missings "$@"

	for package in "${missings[@]}"; do
		echo "$package"
	done
}

# deb.update: Update Debian package index
deb.update() {
	expired 60 /var/cache/apt/pkgcache.bin || apt-get update -y
}

# deb.repository: Add Debian repository
deb.repository() {
	local name=${1?missing argument: name}
	shift

	local url=${1?missing argument: url}
	shift

	has.stdin || die 'Required stdin data'

	if ! deb._apt_key_add "$url"; then
		cat >/etc/apt/sources.list.d/"$name".list
		apt-get update -y
	fi
}

deb._dist_valid() {
	local dist=${1?missing argument: dist}

	http.ok http://ftp.debian.org/debian/dists/"$dist"/
}

deb._dist_added() {
	local dist=${1?missing argument: dist}

	grep -qE "^deb.*\bdebian.org\b.*\b$dist\b" /etc/apt/*.list /etc/apt/sources.list.d/*.list
}

deb._apt_key_add() {
	local url=${1?missing argument: url}

	local tempfile
	temp.file tempfile

	http.get "$url" >"$tempfile" || die "Couldn't get key file: $url"

	local -a questioned_fingerprints installed_fingerprints

	mapfile -t questioned_fingerprints < <(
		gpg -nq --import --import-options import-show --with-colons "$tempfile" | awk -F: '$1 == "fpr" { print $10 }' 2>/dev/null
	)

	# shellcheck disable=2034
	mapfile -t installed_fingerprints < <(
		apt-key adv --list-public-keys --with-fingerprint --with-colon | awk -F: '$1 == "fpr" { print $10 }' 2>/dev/null
	)

	local fingerprint
	for fingerprint in "${questioned_fingerprints[@]}"; do
		included "$fingerprint" "${installed_fingerprints[@]}" || return 1
	done

	apt-key add "$tempfile"

	rm -f -- "$tempfile"
}

deb._missings() {
	local -a deb_missings_=${1?missing argument: array reference}
	shift

	local package
	for package in "${[@]}"; do
		# shellcheck disable=2016
		if [ -z "$(dpkg-query -W -f='${Installed-Size}' "$package" 2>/dev/null ||:)" ]; then
			deb_missings_+=("$package")
		fi
	done
}
