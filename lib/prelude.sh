# Standard prelude

warn() { echo >&2 "$*"; }         ;; abort() { warn "$@"; exit 1; }

[ -n "${BASH_VERSION:-}"        ] || abort 'Bash required.'
[[ ${BASH_VERSINFO[0]:-} -ge 4 ]] || abort 'Bash version 4 or higher required.'
[[ -x /usr/bin/apt-get         ]] || abort 'Only Debian and derivatives supported.'

set -Eeuo pipefail; shopt -s nullglob; [[ -z ${TRACE:-} ]] || set -x; unset CDPATH

export LC_ALL=C.UTF-8 LANG=C.UTF-8
