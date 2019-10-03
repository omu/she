# Default task
default: generate
.PHONY: generate

# Generate she
generate: underscore
.PHONY: generate

underscore: src/underscore $(wildcard lib/*.sh) bin/compile
	bin/compile $< >$@
	chmod +x $@
	bash -n $@
	shellcheck "$@"
