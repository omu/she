INDEXES := execute/index.html source/index.html

all: $(INDEXES)

execute/index.html: index.sh
	@mkdir -p $(dir $@)
	@{ cat $<; printf '\nmain.execute "$$@"\n'; } >$@

source/index.html: index.sh
	@mkdir -p $(dir $@)
	@{ cat $<; printf '\nmain.source "$$@"\n'; } >$@

clean:
	@rm -f $(INDEXES)

.PHONY: clean
