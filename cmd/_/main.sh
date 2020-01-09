#=github.com/omu/home/src/sh/!.sh

# Generic libraries

#=github.com/omu/home/src/sh/_.sh
#=github.com/omu/home/src/sh/color.sh
#=github.com/omu/home/src/sh/deb.sh
#=github.com/omu/home/src/sh/git.sh
#=github.com/omu/home/src/sh/meta.sh
#=github.com/omu/home/src/sh/os.sh
#=github.com/omu/home/src/sh/string.sh
#=github.com/omu/home/src/sh/text.sh
#=github.com/omu/home/src/sh/ui.sh
#=github.com/omu/home/src/sh/virt.sh

# Custom libraries

#=lib/callback.sh
#=lib/defer.sh
#=lib/etc.sh
#=lib/file.sh
#=lib/filetype.sh
#=lib/flag.sh
#=lib/path.sh
#=lib/runtime.sh
#=lib/self.sh
#=lib/src.sh
#=lib/temp.sh
#=lib/url.sh
#=lib/zip.sh

# Commands

#=cmd/_/bin.sh
#=cmd/_/deb.sh
#=cmd/_/etc.sh
#=cmd/_/file.sh
#=cmd/_/filetype.sh
#=cmd/_/git.sh
#=cmd/_/http.sh
#=cmd/_/os.sh
#=cmd/_/self.sh
#=cmd/_/_.sh
#=cmd/_/src.sh
#=cmd/_/text.sh
#=cmd/_/ui.sh
#=cmd/_/url.sh
#=cmd/_/version.sh
#=cmd/_/virt.sh
#=cmd/_/zip.sh

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
	#/help/
	#/command/

	#=lib/main.sh

	main() {
		if ! .interactive && [[ $# -eq 0 ]]; then
			echo "_SELF=$(self.path)"
			echo
			sed 's/^\t\t\t\t//' <<'EOF'
				#=github.com/omu/home/src/sh/!.sh: .prelude+

				declare -gr _SELF=$_SELF

				_() {
					case ${1:-} in
					bug|bye|die)
						"$_SELF" "$@"; exit $?
						;;
					etc|var)
						case ${2:-} in
						get|set)
							local exp

							exp=$("$_SELF" "$@") || exit
							eval -- "$exp"

							return
							;;
						esac
						;;
					src)
						case ${2:-} in
						enter|install)
							local dir
							if dir=$("$_SELF" "$@") && [[ -n $dir ]]; then
								pushd "$dir" &>/dev/null || exit
							fi

							return
							;;
						esac
						;;
					must)
						"$_SELF" "$@" || exit

						return
						;;
					esac

					"$_SELF" "$@"
				}

				[[ $# -eq 0 ]] || _ "$@"
EOF
		else
			.callback init
			.dispatch "$@"
		fi
	}

	main "$@"
fi
