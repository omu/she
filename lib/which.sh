# which.sh - Show facts

# which.virtual: Which virtualization
which.virtual() {
	systemd-detect-virt
}

# which.distribution: Which distribution
which.distribution() {
	# shellcheck disable=1091
	(unset ID && . /etc/os-release 2>/dev/null && echo "$ID")
}

# which.codename: Which distribution release
which.codename() {
	lsb_release -sc
}

# which.mime: Which mime type
which.mime() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	file --mime-type --brief "$file"
}

# which.zmime: Which mime type inside compressed file
which.zmime() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	file --mime-type --brief --uncompress-noreport "$file"
}