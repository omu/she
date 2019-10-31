# deb.sh - Debian package management

# Add Debian repository
deb.add() {
	.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

	# shellcheck disable=2192
	local -A _=(
		[repository]=$NIL
		[key]=
		[deb]=$NIL
		[src]=

		[.help]='repository=NAME deb=LINE [src=LINE] [key=URL]'
		[.argc]=0
	)

	flag.parse

	local repository=${_[repository]:-}

	[[ -n $repository ]] || .bug "Undefined repository."

	[[ -z ${_[key]:-} ]] || deb._key_add "${_[key]}" || return 0

	echo "deb ${_[deb]}"  >/etc/apt/sources.list.d/"$repository".list
	[[ -z ${_[src]:-} ]] || echo "deb-src ${_[src]}" >>/etc/apt/sources.list.d/"$repository".list

	.getting 'Updating package index' apt-get update -y
}

# Install Debian packages
deb.install() {
	.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

	# shellcheck disable=2192
	local -A _=(
		[repository]=
		[key]=
		[deb]=
		[src]=

		[-missings]=false
		[-shiny]=false

		[.help]='[-missings=BOOL] [-shiny=BOOL] [repository=NAME deb=LINE [src=LINE] [key=URL]] PACKAGE...'
		[.argc]=1-
	)

	flag.parse

	[[ $# -gt 0 ]] || return 0

	if [[ -n ${_[repository]:-} ]]; then
		deb.add repository="${_[repository]}" key="${_[key]:-}" deb="${_[deb]:-}" src="${_[src]:-}"
	else
		local arg

		for arg in key deb src; do
			[[ -z ${_[$arg]:-} ]] || .die "Repository required."
		done
	fi

	local -a opts=(
		--yes
		--no-install-recommends
	)

	local -a packages=() urls=() non_urls=()

	local arg
	for arg; do
		local url=$arg

		if url.is "$url" web; then
			urls+=("$url")
		elif url.is "$url" local; then
			non_urls+=("$url")
		else
			.die "Unsupported URL: $url"
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
			.hmm "Using $target"
			deb.using "$target"

			opts+=(
				--target-release
				"$target"
			)
		fi
	fi

	deb.update

	[[ "${#packages[@]}" -eq 0 ]] || .getting 'Installing packages' apt-get install "${opts[@]}" "${packages[@]}"
	[[ "${#urls[@]}" -eq 0     ]] || .running 'Installing packages' deb._install_from_urls "${urls[@]}"
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

# Update Debian package index
deb.update() {
	# shellcheck disable=2192
	local -A _=(
		[.help]=
		[.argc]=0
	)

	flag.parse

	if .expired 60 /var/cache/apt/pkgcache.bin; then
		.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

		.getting 'Updating package index' apt-get update -y
	fi
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

		deb._dist_added "$dist" || deb.add repository="$dist" deb="http://ftp.debian.org/debian $dist main contrib non-free"
	done
}

# deb - Private functions

deb._dist_added() {
	local dist=${1?${FUNCNAME[0]}: missing argument}; shift

	grep -qE "^deb.*\bdebian.org\b.*\b$dist\b" /etc/apt/*.list /etc/apt/sources.list.d/*.list
}

deb._dist_valid() {
	local dist=${1?${FUNCNAME[0]}: missing argument}; shift

	http.is http://ftp.debian.org/debian/dists/"$dist"/ OK
}

deb._installed() {
	local package="${1?${FUNCNAME[0]}: missing argument}"; shift

	[[ -n "$(dpkg-query -W -f='${Installed-Size}' "$package" 2>/dev/null ||:)" ]]
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

deb._key_add() {
	local artifact=

	if [[ ! -d $HOME/.gnupg ]]; then
		artifact=$HOME/.gnupg

		mkdir "$artifact" && chmod 700 "$artifact"
	fi

	local err
	deb._key_add_ "$@"  || err=$? && err=$?

	[[ -z ${artifact:-} ]] || rm -rf "$artifact"

	return "$err"
}

deb._key_add_() {
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

deb._missings() {
	local -n deb_missings_=${1?${FUNCNAME[0]}: missing argument}; shift

	local package
	for package; do
		# shellcheck disable=2016
		deb._installed "$package" || deb_missings_+=("$package")
	done
}

# deb - Init

deb._init() {
	.available apt-get || .die 'Only Debian and derivatives supported.'

	export DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
}

deb._init

