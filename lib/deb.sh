# deb.sh - Debian package management

export DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# deb.install: Install Debian packages
deb.install() {
	# shellcheck disable=2192
	local -A _=(
		[-missings]=false
		[-shiny]=false

		[.help]='PACKAGE...'
	)

	flag.parse

	[[ $# -gt 0 ]] || return 0

	local -a opts=(
		--yes
		--no-install-recommends
	)

	local -a packages urls non_urls

	local arg
	for arg; do
		if is.url "$arg"; then
			urls+=("$arg")
		else
			non_urls+=("$arg")
		fi
	done

	if flag.true missings; then
		deb._missings packages "${non_urls[@]}"
	else
		packages=("${non_urls[@]}")
	fi

	if flag.true shiny; then
		local target

		if is.debian stable; then
			target=$(what.debian codename)-backports
		elif is.debian unstable; then
			target=experimental
		fi

		if [[ -n ${target:-} ]]; then
			deb.using "$target"

			opts+=(
				--target-release
				"$target"
			)
		fi
	fi

	deb.update

	[[ "${#packages[@]}" -eq 0 ]] || apt-get install "${opts[@]}" "${packages[@]}"
	[[ "${#urls[@]}" -eq 0     ]] || deb._install_from_urls "${urls[@]}"
}

# deb.uninstall: Uninstall Debian packages
deb.uninstall() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='PACKAGE...'
	)

	flag.parse

	local -a packages

	deb._missings packages "$@"
	[[ ${#packages[@]} -gt 0 ]] || return 0

	apt-get purge -y "${packages[@]}"

	must.proceed apt-get autoremove -y && must.proceed apt-get autoclean -y
}

# deb.missings: Print missing packages among given packages
deb.missings() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='PACKAGE...'
	)

	flag.parse

	local -a missings
	deb._missings missings "$@"

	for package in "${missings[@]}"; do
		echo "$package"
	done
}

# deb.update: Update Debian package index
# shellcheck disable=2120
deb.update() {
	# shellcheck disable=2192
	local -A _=(
		[.help]=
		[.argc]=0
	)

	flag.parse

	expired 60 /var/cache/apt/pkgcache.bin || apt-get update -y
}

# deb.repository: Add Debian repository
deb.repository() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='NAME [URL]'
		[.argc]=1-
	)

	flag.parse

	local name=$1 url=${2:-}

	must.piped

	if [[ -n ${url:-} ]]; then
		deb._apt_key_add "$url" || return 0
	fi

	cat >/etc/apt/sources.list.d/"$name".list
	apt-get update -y
}

# deb.using: Use given official Debian distributions
deb.using() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='DIST...'
		[.argc]=1-
	)

	flag.parse

	local dist
	for dist; do
		case $dist in
		stable|testing|unstable|sid|experimental)
			;;
		*)
			deb._dist_valid "$dist" || die "Invalid distribution: $dist"
			;;
		esac

		deb._dist_added "$dist" || deb.repository "$dist" <<-EOF
			deb http://ftp.debian.org/debian $dist main contrib non-free
		EOF
	done
}

# deb.sh - Private functions

deb._dist_valid() {
	local dist=${1?${FUNCNAME[0]}: missing argument}; shift

	http.is OK http://ftp.debian.org/debian/dists/"$dist"/
}

deb._dist_added() {
	local dist=${1?${FUNCNAME[0]}: missing argument}; shift

	grep -qE "^deb.*\bdebian.org\b.*\b$dist\b" /etc/apt/*.list /etc/apt/sources.list.d/*.list
}

deb._apt_key_add() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

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
	local -a deb_missings_=${1?${FUNCNAME[0]}: missing argument}; shift

	local package
	for package in "${[@]}"; do
		# shellcheck disable=2016
		if [ -z "$(dpkg-query -W -f='${Installed-Size}' "$package" 2>/dev/null ||:)" ]; then
			deb_missings_+=("$package")
		fi
	done
}

deb._install_from_urls() {
	local url

	for url; do
		local deb

		file.download "$url" deb

		dpkg-deb --info "$deb" &>/dev/null || die "Not a valid Debian package: $url"
		dpkg -i -- "$deb" 2>/dev/null || true
		apt-get -y install --no-install-recommends --fix-broken

		rm -f -- "$deb"
	done
}
