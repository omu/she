# what.sh - Show facts

# what.virtual: Which virtualization
what.virtual() {
	systemd-detect-virt
}

# what.distribution: Which distribution
what.distribution() {
	# shellcheck disable=1091
	(unset ID && . /etc/os-release 2>/dev/null && echo "$ID")
}

# what.codename: Which distribution release
what.codename() {
	lsb_release -sc
}

# what.mime: Which mime type
what.mime() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	file --mime-type --brief "$file"
}

# what.zmime: Which mime type inside compressed file
what.zmime() {
	local file=${1?${FUNCNAME[0]}: missing argument}; shift

	must.f "$file"

	file --mime-type --brief --uncompress-noreport "$file"
}
