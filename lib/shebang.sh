#!/usr/bin/env bash

[ -n "${BASH_VERSION:-}"        ] || { echo >&2 'Bash required.';                     exit 1; }
[[ ${BASH_VERSINFO[0]:-} -ge 4 ]] || { echo >&2 'Bash version 4 or higher required.'; exit 1; }
