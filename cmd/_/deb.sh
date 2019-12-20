# cmd/deb - Debian package management

# Add Debian repository
deb:add() {
	# shellcheck disable=2192
	local -A _=(
		[repository]=$NIL
		[key]=
		[deb]=$NIL
		[src]=

		[.help]='repository=<name> deb=<line> [src=<line>] [key=<url>]'
		[.argc]=0
	)

	flag.parse

	deb:add-
}

# Install Debian packages
deb:install() {
	# shellcheck disable=2192
	local -A _=(
		[repository]=
		[key]=
		[deb]=
		[src]=

		[-missings]=false
		[-shiny]=false

		[.help]='[-missings=<bool>] [-shiny=<bool>] [repository=<name> deb=<line> [src=<line>] [key=<url>]] <package>...'
		[.argc]=1-
	)

	flag.parse

	deb:install- "$@"
}

# Print missing packages among given packages
deb:missings() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='<package>...'
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
		[.help]='<package>...'
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
		[.help]='<dist>...'
		[.argc]=1-
	)

	flag.parse

	deb:using- "$@"
}

# cmd/deb - Private functions

deb:add-() {
	local repository=${_[repository]:-}

	[[ -n $repository ]] || .bug "Undefined repository."

	.privileged

	[[ -z ${_[key]:-} ]] || deb.add-key "${_[key]}" || return 0

	echo "deb ${_[deb]}"  >/etc/apt/sources.list.d/"$repository".list
	[[ -z ${_[src]:-} ]] || echo "deb-src ${_[src]}" >>/etc/apt/sources.list.d/"$repository".list

	.getting 'Updating package index' apt-get update -y
}

deb:install-() {
	[[ $# -gt 0 ]] || return 0

	.privileged

	if [[ -n ${_[repository]:-} ]]; then
		deb:add- repository="${_[repository]}" key="${_[key]:-}" deb="${_[deb]:-}" src="${_[src]:-}"
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

		if url.is "$url" naked; then
			non_urls+=("$url")
		else
			urls+=("$url")
		fi
	done

	if flag.true -missings; then
		deb.missings packages "${non_urls[@]}"
	else
		packages=("${non_urls[@]}")
	fi

	if flag.true -shiny; then
		local target

		if os.is debian/stable; then
			target=$(os.codename)-backports
		elif os.is debian/unstable; then
			target=experimental
		fi

		if [[ -n ${target:-} ]]; then
			.hmm "Using $target"
			deb:using- "$target"

			opts+=(
				--target-release
				"$target"
			)
		fi
	fi

	deb.install "${opts[@]}" "${packages[@]}"
	deb.install-manual "${urls[@]}"
}

deb:using-() {
	local dist
	for dist; do
		case $dist in
		stable|testing|unstable|sid|experimental)
			;;
		*)
			deb.dist-valid "$dist" || .cry "Skipping invalid distribution: $dist"
			;;
		esac

		deb.dist-added "$dist" || deb:add- repository="$dist" deb="http://ftp.debian.org/debian $dist main contrib non-free"
	done
}

# cmd/deb - Init

deb:init-() {
	.available apt-get || .die 'Only Debian and derivatives supported.'

	export DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
}

deb:init-
