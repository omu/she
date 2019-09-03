# File related operations

# bin: Install executable from URL
file.bin() {
	curl -fsSL -o "$2" "$1" && chmod +x "$2"
}

# enter: Get files from URL and chdir to directory
file.enter() {
	local source=$1

	local -A url

	url.parse url "$source"

	local path
	if [[ ${url[protocol]:-} == file ]] ||[[ -n ${FROM_TO:-} ]]; then
		if [[ -n ${FROM_TO:-} ]]; then
			path=$FROM_TO
		else
			path=${url[path]}
		fi
		[[ -d $path ]] || ui.die "No directory: $path"
		cd "$path"     || ui.die "Chdir error: $path"
	elif [[ -n ${url[protocol]:-} ]]; then
		file.tempdir path

		local addr=${url[path]}
		[[ -z ${url[auth]:-} ]] || addr="${url[auth]}@${addr}"
		addr="${url[protocol]}://${addr}"

		cd "$path" || ui.die "Chdir error: $path"

		file.get "$addr"
	else
		ui.die "No protocol found at:$1"
	fi

	if [[ -n ${url[slug]:-} ]]; then
		local slug=${url[slug]}

		[[ -d $slug ]] || ui.die "No directory: $slug"
		cd "./$slug"   || ui.die "Chdir error: $slug"
	fi

	[[ -z ${tmpdir:-} ]] || echo "$tmpdir" >"${SHE_SHIBBOLETH:-.she}"
}

file.get() {
	local source=$1

	local -A url
	url.parse url

	local tempdir
	file.tempdir tempdir
}

file.moveable() {
	:
}

file.move() {
	mv -f "$@"
}
