# which - Show facts

# which.virtual: Which virtualization
which.virtual() {
	systemd-detect-virt
}

# which.distribution: Which distribution
which.distribution() {
	(unset ID && . /etc/os-release 2>/dev/null && echo "$ID")
}

# which.codename: Which distribution release
which.codename() {
	lsb_release -sc
}
