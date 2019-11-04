# cmd/deb - Debian package management

# Add Debian repository
deb:add() {
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

	deb:add_
}

# Install Debian packages
deb:install() {
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

	deb:install_ "$@"
}

# Print missing packages among given packages
deb:missings() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='PACKAGE...'
	)

	flag.parse

	local -a missings
	deb.missings missings "$@"

	for package in "${missings[@]}"; do
		echo "$package"
	done
}

# Uninstall Debian packages
deb:uninstall() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='PACKAGE...'
		[.argc]=1-
	)

	flag.parse

	deb.uninstall "$@"
}

# Update Debian package index
deb:update() {
	# shellcheck disable=2192
	local -A _=(
		[.help]=
		[.argc]=0
	)

	flag.parse

	deb.update
}

# Use given official Debian distributions
deb:using() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='DIST...'
		[.argc]=1-
	)

	flag.parse

	deb:using_ "$@"
}

# deb - Protected functions

deb:add_() {
	local repository=${_[repository]:-}

	[[ -n $repository ]] || .bug "Undefined repository."

	.must 'Root permissions required; use sudo.' [[ ${EUID:-} -eq 0 ]]

	[[ -z ${_[key]:-} ]] || deb.add_key "${_[key]}" || return 0

	echo "deb ${_[deb]}"  >/etc/apt/sources.list.d/"$repository".list
	[[ -z ${_[src]:-} ]] || echo "deb-src ${_[src]}" >>/etc/apt/sources.list.d/"$repository".list

	.getting 'Updating package index' apt-get update -y
}

deb:install_() {
	[[ $# -gt 0 ]] || return 0

	if [[ -n ${_[repository]:-} ]]; then
		deb.add_ repository="${_[repository]}" key="${_[key]:-}" deb="${_[deb]:-}" src="${_[src]:-}"
	else
		local arg

		for arg in key deb src; do
			[[ -z ${_[$arg]:-} ]] || .die "Repository required."
		done
	fi

	local -a packages=() urls=() non_urls=() opts=()

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
		deb.missings packages "${non_urls[@]}"
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
			deb:using_ "$target"

			opts+=(
				--target-release
				"$target"
			)
		fi
	fi

	deb.install "${opts[@]}" "${packages[@]}"
	deb.install_manual "${urls[@]}"
}

deb:using_() {
	local dist
	for dist; do
		case $dist in
		stable|testing|unstable|sid|experimental)
			;;
		*)
			deb.dist_valid "$dist" || .cry "Skipping invalid distribution: $dist"
			;;
		esac

		deb.dist_added "$dist" || deb:add_ repository="$dist" deb="http://ftp.debian.org/debian $dist main contrib non-free"
	done
}

# cmd/deb - Init

deb:init_() {
	.available apt-get || .die 'Only Debian and derivatives supported.'

	export DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
}

deb:init_
