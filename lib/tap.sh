readonly _TAP_VERSION_=13

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

tap.version() {
	local -A _=(
		[.argc]=0
	)

	echo TAP version $_TAP_VERSION_
	echo
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
	echo "# ${_[success]} test(s) succeeded, ${_[failure]} test(s) failed, ${_[skip]} test(s) skipped."
	echo "# There are ${_[todo]} todo test(s) waiting to be completed."
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
	ui.out success

	if [[ -n ${_[number]:-} ]]; then
		echo "${_[number]} - ${_[test]}"
	else
		echo "${_[test]}"
	fi | color.out +blue
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
	ui.out failure

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
	ui.out question

	{
		if [[ -n ${_[number]:-} ]]; then
			echo -n "${_[number]} - ${_[test]}"
		else
			echo -n "${_[test]}"
		fi

		color.echo +yellow ' # SKIP'
	} | color.out +blue
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
	ui.out failure

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

tap.out() {
	sed 's:^:# out> :' | color.out +green
}

tap.err() {
	sed 's:^:# err> :' | color.out +red
}

tap.stack() {
	sed 's:^:# :' | color.out yellow
}
