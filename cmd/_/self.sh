# cmd/self - Commands related to theprogram itself

# Install self
self:install() {
	# shellcheck disable=2192,2128
	local -A _=(
		[-prefix]="${PERSISTENT[bin]}"
		[-name]=$PROGNAME

		[.help]='[-prefix=<dir>] [-name=<name>]'
		[.argc]=0
	)

	flag.parse

	_[1]=$(self.path)

	bin:install_
}

# Print self name
self:name() {
	local -A _; flag.parse

	self.name
}

# Print self path
self:path() {
	local -A _; flag.parse

	self.path
}

# Print self source
self:src() {
	local -A _; flag.parse

	self.src
}
