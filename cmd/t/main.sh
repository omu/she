#=github.com/omu/home/src/sh/!.sh
#=github.com/omu/home/src/sh/_.sh

#=github.com/omu/home/src/sh/assert.sh
#=github.com/omu/home/src/sh/color.sh
#=github.com/omu/home/src/sh/callback.sh
#=github.com/omu/home/src/sh/defer.sh
#=github.com/omu/home/src/sh/flag.sh
#=github.com/omu/home/src/sh/self.sh
#=github.com/omu/home/src/sh/ui.sh

#:cmd/t/t.sh
#:cmd/t/version.sh

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
	#/help/
	#/command/

	#=github.com/omu/home/src/sh/main.sh

	main() {
		if ! .interactive && [[ $# -eq 0 ]]; then
			echo "readonly _SELF=$(self.path)"
			echo
			sed 's/^\t\t\t\t//' <<'EOF'
				#=github.com/omu/home/src/sh/!.sh

				#=github.com/omu/home/src/sh/assert.sh
				#=github.com/omu/home/src/sh/defer.sh
				#=github.com/omu/home/src/sh/temp.sh: temp.dir temp.clean

				#:cmd/t/t.sh

				t() {
					local cmd

					[[ $# -gt 0 ]] || .die 'Test command required'

					cmd=$1
					shift

					[[ $cmd =~ ^[a-z][a-z0-9-]+$ ]] || .die "Invalid command name: $cmd"

					if .callable t:"$cmd"; then
						t:"$cmd" "$@"
					else
						tap "$@"
					fi
				}

				[[ $# -eq 0 ]] || .load "$@"

				[[ -z "${BASH_SOURCE[1]:-}" ]] || tap startup "${BASH_SOURCE[1]}"

EOF
		else
			.dispatch "$@"
		fi
	}

	main "$@"
fi
