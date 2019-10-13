tap.suite_starting() {
	local file=$1

	echo "# Running tests in $file"
}

tap.starting() {
	echo -n
}

tap.pending() {
	local test=$1

	echo -n ok | ui.out warning
	echo -n "$test" | color.out +blue
	echo ' # skip test to be written' | color.out +yellow
}

# Success
tap.success() {
	local test=$1

	echo -n ok | ui.out success
	echo "$test" | color.out +blue
}

# Failure
tap.failure() {
	local test=$1 msg=${2:-}

	echo -n 'not ok' | ui.out failure
	echo "$test" | color.out +blue
	[[ -z ${msg:-} ]] || printf -- "%s\n" "$msg" | sed -u -e 's/^/# /'
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
