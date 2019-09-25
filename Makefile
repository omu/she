# Default task
default: generate
.PHONY: generate

# Generate she
generate: she
.PHONY: generate

she: src/she $(wildcard lib/*.sh) bin/compile
	bin/compile $< >$@
	bash -n $@
	shellcheck "$@"
