# Initialize underscore system

.() {
	# Program name
	const PROGNAME "${0##*/}"

	# Core environment
	if [[ ${EUID:-} -eq 0 ]]; then
		local etc=/usr/local/etc/_
		[[ ! $PROGNAME =~ /usr/bin ]] || etc=/etc/_

		const _SRC_DIR        "${UNDERSCORE_SRC_DIR:-}"   "${SRCDIR:-}"   /run/_/src
		const _TMP_DIR        "${UNDERSCORE_TMP_DIR:-}"   "${TMPDIR:-}"   /run/_/tmp
		const _ETC_DIR        "${UNDERSCORE_ETC_DIR:-}"   "${ETCDIR:-}"   "$etc"
		const _CACHE_DIR      "${UNDERSCORE_CACHE_DIR:-}" "${CACHEDIR:-}" /run/_/cache
		const _VAR_DIR        "${UNDERSCORE_VAR_DIR:-}"   "${VARDIR:-}"   /run/_/var
	else
		const XDG_RUNTIME_DIR "${XDG_RUNTIME_DIR:-}"      /run/"$EUID"
		const XDG_CONFIG_HOME "${XDG_CONFIG_HOME:-}"      "$HOME"/.config
		const XDG_CACHE_HOME  "${XDG_CACHE_HOME:-}"       "$HOME"/.cache

		const _SRC_DIR        "${UNDERSCORE_SRC_DIR:-}"   "${SRCDIR:-}"   "$HOME"/.local/src
		const _TMP_DIR        "${UNDERSCORE_TMP_DIR:-}"   "${TMPDIR:-}"   "$XDG_RUNTIME_DIR"/_/tmp
		const _ETC_DIR        "${UNDERSCORE_ETC_DIR:-}"   "${ETCDIR:-}"   "$XDG_CONFIG_HOME"/_
		const _CACHE_DIR      "${UNDERSCORE_CACHE_DIR:-}" "${CACHEDIR:-}" "$XDG_CACHE_HOME"/_
		const _VAR_DIR        "${UNDERSCORE_VAR_DIR:-}"   "${VARDIR:-}"   "$XDG_RUNTIME_DIR"/_/var
	fi

	unset -f "${FUNCNAME[0]}"
}

. # init