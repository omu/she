#=github.com/omu/home/src/sh/!.sh
#=github.com/omu/home/src/sh/_.sh

#=github.com/omu/home/src/sh/color.sh
#=github.com/omu/home/src/sh/flag.sh
#=github.com/omu/home/src/sh/ui.sh

#:cmd/tap/tap.sh

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
	#/help/
	#/command/

	#=github.com/omu/home/src/sh/main.sh

	main() {
		.dispatch "$@"
	}

	main "$@"
fi
