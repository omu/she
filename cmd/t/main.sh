#=github.com/omu/home/src/sh/!.sh

# Generic libraries

#=github.com/omu/home/src/sh/_.sh
#=github.com/omu/home/src/sh/color.sh
#=github.com/omu/home/src/sh/meta.sh
#=github.com/omu/home/src/sh/ui.sh

# Custom libraries

#=lib/assert.sh
#=lib/callback.sh
#=lib/defer.sh
#=lib/flag.sh
#=lib/runtime.sh
#=lib/self.sh

# Commands

#:cmd/t/t.sh
#:cmd/t/version.sh

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
	#/help/
	#/command/

	#=lib/main.sh

	main() {
		if ! .interactive && [[ $# -eq 0 ]]; then
			echo "readonly _SELF=$(self.path)"
			echo
			sed 's/^\t\t\t\t//' <<'EOF'
				#=github.com/omu/home/src/sh/!.sh

				#=lib/assert.sh
				#=lib/defer.sh
				#=lib/temp.sh: temp.dir temp.clean

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
