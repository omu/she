# tap.sh - TAP functions

# Mark stdin lines as an error output
tap.err() {
	local -A _; flag.parse

	sed 's:^:# err> :' | color.out +red
}

# Print TAP failure
tap.failure() {
	# shellcheck disable=2192
	local -A _=(
		[test]=$NIL
		[number]=

		[.help]='test=MSG [number=NUM] [MSG...]'
		[.argc]=0-
	)

	flag.parse

	echo -n 'not ok '
	ui.out notok

	if [[ -n ${_[number]:-} ]]; then
		echo "${_[number]} - ${_[test]}"
	else
		echo "${_[test]}"
	fi | color.out +blue

	local message
	for message; do
		echo "$message"
	done | sed -u -e 's/^/# /'
}

# Mark stdin lines as a successful output
tap.out() {
	local -A _; flag.parse

	sed 's:^:# out> :' | color.out +green
}

# Print TAP plan
tap.plan() {
	# shellcheck disable=2192
	local -A _=(
		[total]=$NIL

		[.help]='total=NUM'
	)

	flag.parse

	echo "1..${_[total]}"
	echo
}

# Print TAP summary
tap.shutdown() {
	# shellcheck disable=2192
	local -A _=(
		[failure]=$NIL
		[skip]=0
		[success]=$NIL
		[todo]=0
		[total]=$NIL

		[.help]='total=NUM success=NUM failure=NUM [todo=NUM] [skip=NUM]'
	)

	flag.parse

	echo "# ${_[success]} test(s) succeeded, ${_[failure]} test(s) failed, ${_[skip]} test(s) skipped."
	echo "# There are ${_[todo]} todo test(s) waiting to be done."
}


# Print TAP skip
tap.skip() {
	# shellcheck disable=2192
	local -A _=(
		[test]=$NIL
		[number]=

		[.help]='test=MSG [number=NUM]'
	)

	flag.parse

	echo -n 'ok     '
	ui.out default

	{
		if [[ -n ${_[number]:-} ]]; then
			echo -n "${_[number]} - ${_[test]}"
		else
			echo -n "${_[test]}"
		fi

		color.echo +yellow ' # SKIP'
	} | color.out +blue
}

# Print TAP start
tap.startup() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='[FILE]'
		[.argc]=1
	)

	flag.parse

	local file=$1

	echo "# Running tests in $file"
	echo
}

# Print TAP success
tap.success() {
	# shellcheck disable=2192
	local -A _=(
		[test]=$NIL
		[number]=

		[.help]='test=MSG [number=NUM]'
	)

	flag.parse

	echo -n 'ok     '
	ui.out ok

	if [[ -n ${_[number]:-} ]]; then
		echo "${_[number]} - ${_[test]}"
	else
		echo "${_[test]}"
	fi | color.out +blue
}

# Print TAP version
tap.version() {
	local -A _=(
		[.argc]=0
	)

	echo TAP version "$_TAP_VERSION_"
	echo
}

# Print TAP todo
tap.todo() {
	# shellcheck disable=2192
	local -A _=(
		[test]=$NIL
		[number]=

		[.help]='test=MSG [number=NUM]'
	)

	flag.parse

	echo -n 'not ok '
	ui.out notok

	{
		if [[ -n ${_[number]:-} ]]; then
			echo -n "${_[number]} - ${_[test]}"
		else
			echo -n "${_[test]}"
		fi

		color.echo +yellow ' # TODO'
	} | color.out +blue

	local message
	for message; do
		echo "$message"
	done | sed -u -e 's/^/# /'
}

# tap - Protected functions

tap.stack() {
	sed 's:^:# :' | color.out yellow
}

# tap - Init

tap._init() {
	readonly _TAP_VERSION_=13
}

tap._init
