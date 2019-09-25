# prelude.sh - Standard prelude

[ -n "${BASH_VERSION:-}"        ] || { echo >&2 'Bash required.';                         exit 1; }
[[ ${BASH_VERSINFO[0]:-} -ge 4 ]] || { echo >&2 'Bash version 4.4 or higher required.';   exit 1; }
[[ ${BASH_VERSINFO[1]:-} -ge 4 ]] || { echo >&2 'Bash version 4.4 or higher required.';   exit 1; }
[[ -x /usr/bin/apt-get         ]] || { echo >&2 'Only Debian and derivatives supported.'; exit 1; }

set -Eeuo pipefail; shopt -s nullglob; [[ -z ${TRACE:-} ]] || set -x; unset CDPATH

export LC_ALL=C.UTF-8 LANG=C.UTF-8
