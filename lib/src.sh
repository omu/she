# src.sh - Source cache management

src.del() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ $# -gt 0 ]]; then
		# shellcheck disable=2178
		local -n _src_=$1
		shift
	else
		local -A _src_=()
	fi

	src.plan "$url" _src_ && src.rm-
}

src.enter() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ $# -gt 0 ]]; then
		# shellcheck disable=2178
		local -n _src_=$1
		shift
	else
		local -A _src_=()
	fi

	src.plan "$url" _src_ && src.apply-
	src.enter-
}

src.get() {
	local url=${1?${FUNCNAME[0]}: missing argument}; shift

	if [[ $# -gt 0 ]]; then
		# shellcheck disable=2178
		local -n _src_=$1
		shift
	else
		local -A _src_=()
	fi

	src.plan "$url" _src_ && src.apply-
}

# shellcheck disable=2034
src.plan() {
	local url=${1?${FUNCNAME[0]}: missing argument};           shift
	local -n _src_plan_=${1?${FUNCNAME[0]}: missing argument}; shift

	src.calculate- "$url" _src_plan_
}

src.purge() {
	if [[ $# -gt 0 ]]; then
		# shellcheck disable=2178
		local -n _src_=$1
		shift

		local caches=${_src_[cache]%/*} temps=${_src_[temp]%/*}
		rm -rf -- "$caches" "$temps"
	else
		[[ -z ${SRCTMP:-} ]] || rm -rf -- "$SRCTMP"/{src,tmp}
	fi
}

# Private functions

src.apply-() {
	src.prep-

	if [[ -e ${_src_[cache]} ]]; then
		src.ok- || src.renew-
	else
		src.new-
	fi
}

# shellcheck disable=2034,2154
src.calculate-() {
	local url=${1?${FUNCNAME[0]}: missing argument};       shift
	local -n _hash_=${1?${FUNCNAME[0]}: missing argument}; shift

	local cachedir=${_hash_[-cachedir]:-}
	if [[ -z $cachedir ]]; then
		[[ -n ${SRCCACHE:-} ]] || .die 'SRCCACHE undefined'

		cachedir=$SRCCACHE
	fi

	local tempdir=${_hash_[-tempdir]:-}
	if [[ -z $tempdir ]]; then
		[[ -n ${SRCTEMP:-} ]] || .die 'SRCTEMP undefined'

		tempdir=$SRCTEMP
	fi

	local -A _result_
	url.parse -bash=_result_ "$url" || .die "Error parsing URL: $url"

	_result_[cache]=$cachedir/${_result_[id]}
	_result_[temp]=$tempdir/${_result_[id]}

	.merge _hash_ _result_
}

src.enter-() {
	[[ -d ${_src_[cache]} ]] || return 0
	.must -- cd "${_src_[cache]}"

	[[ -d ${_src_[inpath]} ]] || return 0
	.must -- cd "${_src_[inpath]}"
}

src.handler-() {
	local handler

	case ${_src_[class]:-} in
	"")                handler=none ;;
	git)               handler=git ;;
	zip|tar.gz|tar.xz) handler=zip ;;
	*)                 .die "Unsupported class: ${_src_[class]}"
	esac

	echo "$handler"
}

src.prep-() {
	local caches=${_src_[cache]%/*} temps=${_src_[temp]%/*}

	[[ -d $caches ]] || .must -- mkdir -p "$caches"
	[[ -d $temps  ]] || .must -- mkdir -p "$temps"
}

src.ln-() {
	local dst=${1?${FUNCNAME[0]}: missing argument}; shift

	src.rm- && cp -al "$dst" "${_src_[cache]}"
}

src.mv-() {
	[[ -e ${_src_[temp]} ]] || return 0

	src.rm- && mv "${_src_[temp]}" "${_src_[cache]}"
}

src.new-() {
	if [[ ${_src_[scheme]} = file ]]; then
		src.ln- "${_src_[source]}"
	else
		.clean "${_src_[temp]}"

		src.rm-

		local handler
		handler=$(src.handler-) || exit $?

		src."$handler".new-

		src.mv-
	fi

	touch "${_src_[cache]}"
}

src.ok-() {
	[[ -e ${_src_[cache]} ]] || return 1

	local ttl=${_src_[-ttl]:-}
	[[ -n $ttl ]] || ttl=${SRCTTL:-30}

	! .expired "$ttl" "${_src_[cache]}"
}

src.planned-() {
	[[ -n ${_src_[source]:-}  ]] || .bug "Unplanned cache"

	[[ -n ${_src_[cache]:-} ]] || .bug "Unplanned cache: ${_src_[source]}"
	[[ -n ${_src_[temp]:-}  ]] || .bug "Unplanned temp: ${_src_[source]}"
}

src.renew-() {
	if [[ ${_src_[scheme]} = file ]]; then
		src.ln- "${_src_[source]}"
	else
		.clean "${_src_[temp]}"

		local handler
		handler=$(src.handler-) || exit $?

		src."$handler".renew-
		src.mv-
	fi

	touch "${_src_[cache]}"
}

src.rm-() {
	rm -rf "${_src_[cache]}"
}

# src - Git

src.git.new-() {
	git.clone "${_src_[source]}" "${_src_[temp]}" "${_src_[ref]}"
}

src.git.renew-() {
	git.reset "${_src_[cache]}" && git.update "${_src_[cache]}"
}

# src - Zip

src.zip.new-() {
	src.none.new-

	local dst="${_src_[temp]}".unpack

	rm -rf -- "$dst" && zip.unpack "${_src_[temp]}" "$dst"
	rm -rf -- "${_src_[temp]}" && mv "$dst" "${_src_[temp]}"
}

src.zip.renew-() {
	src.zip.new-
}

# src - None

src.none.new-() {
	[[ ${_src_[scheme]} =~ ^http ]] || .bug "Unimplemented scheme: ${_src_[scheme]}"

	http.download "${_src_[source]}" "${_src_[temp]}"
}

src.none.renew-() {
	src.none.new-
}
