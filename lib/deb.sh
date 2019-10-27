# deb.sh - Debian package management

.available apt-get || .die 'Only Debian and derivatives supported.'

export DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# Install Debian packages
deb.install() {
	.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

	# shellcheck disable=2192
	local -A _=(
		[-missings]=false
		[-shiny]=false

		[.help]='PACKAGE...'
		[.argc]=1-
	)

	flag.parse

	[[ $# -gt 0 ]] || return 0

	local -a opts=(
		--yes
		--no-install-recommends
	)

	local -a packages=() urls=() non_urls=()

	local arg
	for arg; do
		local url=$arg

		if url.getable url; then
			urls+=("$url")
		else
			non_urls+=("$url")
		fi
	done

	if flag.true -missings; then
		deb._missings packages "${non_urls[@]}"
	else
		packages=("${non_urls[@]}")
	fi

	if flag.true -shiny; then
		local target

		if os.is debian stable; then
			target=$(os.codename)-backports
		elif os.is debian unstable; then
			target=experimental
		fi

		if [[ -n ${target:-} ]]; then
			ui.info "Using $target"
			deb.using "$target"

			opts+=(
				--target-release
				"$target"
			)
		fi
	fi

	deb.update

	[[ "${#packages[@]}" -eq 0 ]] || .net 'Installing packages' apt-get install "${opts[@]}" "${packages[@]}"
	[[ "${#urls[@]}" -eq 0     ]] || deb._install_from_urls "${urls[@]}"
}

# Uninstall Debian packages
deb.uninstall() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='PACKAGE...'
		[.argc]=1-
	)

	flag.parse

	local -a packages=()

	deb._missings packages "$@"
	[[ ${#packages[@]} -gt 0 ]] || return 0

	.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

	apt-get purge -y "${packages[@]}"

	.should -- apt-get autoremove -y
	.should -- apt-get autoclean -y
}

# Print missing packages among given packages
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

# Update Debian package index
# shellcheck disable=2120
deb.update() {
	# shellcheck disable=2192
	local -A _=(
		[.help]=
		[.argc]=0
	)

	flag.parse

	if .expired 60 /var/cache/apt/pkgcache.bin; then
		.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

		.net 'Updating package index' apt-get update -y
	fi
}

# Add Debian repository
deb.repository() {
	.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]
	.must 'No data found at stdin' .piped

	# shellcheck disable=2192
	local -A _=(
		[.help]='NAME [URL]'
		[.argc]=1-
	)

	flag.parse

	local name=$1 url=${2:-}

	if [[ -n ${url:-} ]]; then
		deb._apt_key_add "$url" || return 0
	fi

	cat >/etc/apt/sources.list.d/"$name".list
	.net 'Updating package index' apt-get update -y
}

# Use given official Debian distributions
deb.using() {
	.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

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
			deb._dist_valid "$dist" || .cry "Skipping invalid distribution: $dist"
			;;
		esac

		deb._dist_added "$dist" || deb.repository "$dist" <<-EOF
			deb http://ftp.debian.org/debian $dist main contrib non-free
		EOF
	done
}

# deb - Private functions

deb._dist_valid() {
	local dist=${1?${FUNCNAME[0]}: missing argument}; shift

	http.is http://ftp.debian.org/debian/dists/"$dist"/ OK
}

deb._dist_added() {
	local dist=${1?${FUNCNAME[0]}: missing argument}; shift

	grep -qE "^deb.*\bdebian.org\b.*\b$dist\b" /etc/apt/*.list /etc/apt/sources.list.d/*.list
}

deb._apt_key_add() {
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

	local fingerprint
	for fingerprint in "${questioned_fingerprints[@]}"; do
		.contains "$fingerprint" "${installed_fingerprints[@]}" || return 1
	done

	apt-key add "$temp_file"

	temp.clean temp_file
}

deb._missings() {
	local -a deb_missings_=${1?${FUNCNAME[0]}: missing argument}; shift

	local package
	for package; do
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

		dpkg-deb --info "$deb" &>/dev/null || .die "Not a valid Debian package: $url"
		dpkg -i -- "$deb" 2>/dev/null || true
		apt-get -y install --no-install-recommends --fix-broken

		rm -f -- "$deb"
	done
}
