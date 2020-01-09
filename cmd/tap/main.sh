#=github.com/omu/home/src/sh/!.sh

# Generic libraries

#=github.com/omu/home/src/sh/_.sh
#=github.com/omu/home/src/sh/color.sh
#=github.com/omu/home/src/sh/ui.sh

# Custom libraries

#=lib/flag.sh

# Commands

#:cmd/tap/tap.sh

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
	#/help/
	#/command/

	#=lib/main.sh

	main() {
		.dispatch "$@"
	}

	main "$@"
fi
