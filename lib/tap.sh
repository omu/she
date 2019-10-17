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
		[total]=$NIL

		[.help]='total=NUM'
	)

	flag.parse

	echo "1..${_[total]}"
}

tap.pending() {
	# shellcheck disable=2192
	local -A _=(
		[test]=$NIL
		[number]=

		[.help]='test=MSG [number=NUM]'
	)

	flag.parse

	echo -n ok | ui.out warning

	if [[ -n ${_[number]:-} ]]; then
		echo "${_[number]} - ${_[test]}"
	else
		echo "${_[test]}"
	fi | color.out +blue

	echo ' # skip test to be written' | color.out +yellow
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

	echo -n 'ok '
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
		[error]=

		[.help]='test=MSG [number=NUM] [error=MSG]'
	)

	flag.parse

	echo -n 'not ok' | ui.out failure

	if [[ -n ${_[number]:-} ]]; then
		echo "${_[number]} - ${_[test]}"
	else
		echo "${_[test]}"
	fi | color.out +blue

	[[ -z ${_[error]:-} ]] || printf -- "%s\n" "${_[error]}" | sed -u -e 's/^/# /'
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
