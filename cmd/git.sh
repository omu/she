# cmd/git - Git commands

# Git pull if repository expired
git:update() {
	local -A _=(
		[-expiry]=3

		[.help]='[-expiry=MINUTES]'
		[.argc]=0
	)

	flag.parse

	if .expired "${_[-expiry]}" .git/FETCH_HEAD; then
		git.must.clean
		.getting 'Updating repository' git pull --quiet origin
	fi
}
