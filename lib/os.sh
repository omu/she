# os.sh - OS related functions

# Assert any OS feature
os.any() {
	local -A _=(
		[.help]='FEATURE...'
		[.argc]=1-
	)

	flag.parse

	local feature

	for feature; do
		if os._is "$feature"; then
			return 0
		fi
	done

	return 1
}

# Print distribution codename
os.codename() {
	local -A _; flag.parse

	lsb_release -sc
}

# Print distribution name
os.dist() {
	local -A _; flag.parse

	# shellcheck disable=1091
	(unset ID && . /etc/os-release 2>/dev/null && echo "$ID")
}

# Assert OS feature
os.is() {
	local -A _=(
		[.help]='FEATURE'
		[.argc]=1
	)

	flag.parse

	os._is "$@"
}

# os - Private functions

os._is() {
	local feature=${1?${FUNCNAME[0]}: missing argument}; shift

	local func=os.is._"${feature}"

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

os.is._proxmox() {
	.available pveversion && uname -a | grep -q -i pve
}

os.is._sid() {
	grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
}

os.is._stable() {
	! os.is._unstable
}

os.is._unstable() {
	grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
}

os.is._testing() {
	grep -qwE '(sid|unstable)' /etc/debian_version 2>/dev/null
}
