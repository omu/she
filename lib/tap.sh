tap.startup() {
	local file=$1

	echo "# Running tests in $file"
}

tap.begin() {
	echo -n
}

tap.pending() {
	local test=$1 number=${2:-}

	echo -n ok | ui.out warning

	if [[ -n ${number:-} ]]; then
		echo "$number - $test"
	else
		echo "$test"
	fi | color.out +blue

	echo ' # skip test to be written' | color.out +yellow
}

# Success
tap.success() {
	local test=$1 number=${2:-}

	echo -n ok | ui.out success

	if [[ -n ${number:-} ]]; then
		echo "$number - $test"
	else
		echo "$test"
	fi | color.out +blue
}

# Failure
tap.failure() {
	local test=$1 reason=${2:-} number=${3:-}

	echo -n 'not ok' | ui.out failure

	if [[ -n ${number:-} ]]; then
		echo "$number - $test"
	else
		echo "$test"
	fi | color.out +blue

	[[ -z ${reason:-} ]] || printf -- "%s\n" "$reason" | sed -u -e 's/^/# /'
}

tap.summary() {
	:
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
