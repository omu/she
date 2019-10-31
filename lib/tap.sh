readonly _TAP_VERSION_=13

tap.err() {
	sed 's:^:# err> :' | color.out +red
}

# Failure
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

tap.out() {
	sed 's:^:# out> :' | color.out +green
}

tap.plan() {
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

	echo "1..${_[total]}"
	echo
	echo "# ${_[success]} test(s) succeeded, ${_[failure]} test(s) failed, ${_[skip]} test(s) skipped."
	echo "# There are ${_[todo]} todo test(s) waiting to be done."
}

tap.shutdown() {
	# shellcheck disable=2192
	local -A _=(
		[total]=$NIL
		[success]=$NIL
		[failure]=$NIL
		[duration]=$NIL

		[.help]='total=NUM success=NUM failure=NUM duration=SECONDS'
	)

	flag.parse

	:
}

# Skip
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

tap.startup() {
	# shellcheck disable=2192
	local -A _=(
		[.help]='[FILE]'
		[.argc]=1
	)

	flag.parse

	local file=$1

	echo "# Running tests in $file"
}

# Success
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

tap.stack() {
	sed 's:^:# :' | color.out yellow
}

tap.version() {
	local -A _=(
		[.argc]=0
	)

	echo TAP version $_TAP_VERSION_
	echo
}

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
