# cmd/git - Git commands

# Git pull if repository expired
git:update() {
	local -A _=(
		[-ttl]=3

		[.help]='[-ttl=MINUTES]'
		[.argc]=0
	)

	flag.parse

	if .expired "${_[-ttl]}" .git/FETCH_HEAD; then
		git.must.clean
		.getting 'Updating repository' git pull --quiet origin
	fi
}
