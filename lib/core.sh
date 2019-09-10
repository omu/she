# Core functions

# cry: Print warning messages on standard error
cry() {
	local message

	for message; do
		echo >&2 "$message"
	done
}

# die: Print error messages and exit failure
die() {
	local message

	for message; do
		echo >&2 "E: $message"
	done

        exit 1
}

# bug: Report bug and exit failure
bug() {
	local message

	for message; do
		echo >&2 "B: ${BASH_LINENO[0]}: $message"
	done

	exit 127
}

# fin: Print messages and exit successfully
fin() {
	cry "$@"
	exit 0
}

# Command must success
must() {
	"$@" || die "Command failed: $*"
}

# Command may fail
might() {
	"$@" || cry "Exit code $? is suppressed: $*"
}

# Announce constant (readonly) environment variable
const() {
	local export=

	while [[ $# -gt 0 ]]; do
		case $1 in
		-x|-export|--export)
			export=
			shift
			;;
		-*)
			die "Unrecognized flag: $1"
			;;
		*)
			break
			;;
		esac
	done

	local -n variable_=$1
	shift

	local value_
	for value_; do
		if [[ -n $value_ ]]; then
			# shellcheck disable=2034
			variable_=$value_

			declare -gr "${!variable_}"
			[[ -z ${export:-} ]] || export "${!variable_}"

			break
		fi
	done
}

# Ensure that the directory pointed by given environment variable exists
ensured() {
	local -n variable_=$1

	[[ -n ${!variable_} ]] || die "Blank environment value found: $variable_"
	must mkdir -p "${!variable_}"
}