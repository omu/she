# _.sh - Underscore spesific functions

# Core environment
# shellcheck disable=2120
.runtime() {
	# Default variable as a hash
	declare -gA _=()

	# shellcheck disable=2034
	if [[ ${EUID:-} -eq 0 ]]; then
		local volatile=${1:-/run/_} persistent=${2:-/usr/local}

		[[ -v VOLATILE ]] || declare -Agr VOLATILE=(
			[0]="$volatile"

			[bin]="$volatile"/bin
			[doc]="$volatile"/doc
			[etc]="$volatile"/etc
			[lib]="$volatile"/lib
			[opt]="$volatile"/opt
			[srv]="$volatile"/srv
			[src]="$volatile"/src
			[tmp]="$volatile"/tmp
			[var]="$volatile"/var
		)

		[[ -v PERSISTENT ]] || declare -Agr PERSISTENT=(
			[0]="$persistent"

			[bin]="$persistent"/bin
			[doc]="$persistent"/doc
			[etc]="$persistent"/etc
			[lib]="$persistent"/lib
			[opt]=/opt
			[src]="$persistent"/src
			[srv]=/srv
			[tmp]="${TMPDIR:-/var/local/tmp}"
			[var]=/var/local
		)
	else
		local volatile=${1:-${XDG_RUNTIME_DIR:-/run/user/"$EUID"/_}} persistent=${2:-~/.local}

		[[ -v VOLATILE ]] || declare -Agr VOLATILE=(
			[0]="$volatile"

			[bin]="$volatile"/bin
			[doc]="$volatile"/doc
			[etc]="$volatile"/etc
			[lib]="$volatile"/lib
			[opt]="$volatile"/opt
			[srv]="$volatile"/srv
			[src]="$volatile"/src
			[tmp]="$volatile"/tmp
			[var]="$volatile"/var
		)

		[[ -v PERSISTENT ]] || declare -Agr PERSISTENT=(
			[0]="$persistent"

			[bin]="$persistent"/bin
			[doc]="$persistent"/doc
			[etc]="${XDG_CONFIG_HOME:-~/.config}"
			[lib]="$persistent"/lib
			[opt]="$persistent"/opt
			[src]="$persistent"/src
			[srv]="$persistent"/srv
			[tmp]="${TMPDIR:-${XDG_CACHE_HOME:-~/.cache}/tmp}"
			[var]="${XDG_CACHE_HOME:-~/.cache}"
		)
	fi

	local path
	for path in "${PERSISTENT[bin]}" "${VOLATILE[bin]}"; do
		case ":$PATH:" in
		*:"$path":*)	                     ;;
		*)		PATH="$path":"$PATH" ;;
		esac
	done

	# shellcheck disable=2128
	export PATH SRCCACHE="${VOLATILE[src]}" SRCTEMP="${VOLATILE[tmp]}"
}

# shellcheck disable=2119
.runtime
