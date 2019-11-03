# os.sh - OS related functions

os.any() {
	local feature

	for feature; do
		if os.is "$feature"; then
			return 0
		fi
	done

	return 1
}

os.codename() {
	lsb_release -sc
}

os.dist() {
	# shellcheck disable=1091
	(unset ID && . /etc/os-release 2>/dev/null && echo "$ID")
}

os.is() {
	local feature=${1?${FUNCNAME[0]}: missing argument}; shift

	local func=os.is."${feature}"

	if .callable "$func"; then
		"$func"
	else
		local dist
		dist=$(os.dist)

		if [[ $dist = "$feature" ]]; then
			return 0
		fi

		local codename
		codename=$(os.codename)

		if [[ $codename = "$feature" ]]; then
			return 0
		fi

		return 1
	fi
}

os.is.proxmox() {
	.available pveversion && uname -a | grep -q -i pve
}

os.is.sid() {
	grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
}

os.is.stable() {
	! os.is.unstable
}

os.is.unstable() {
	grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
}

os.is.testing() {
	os.is.unstable
}
