
ifeq ($(BUILDNAME),)
	BUILDNAME=master
endif

all: shar

shar:
	./mk-agents-shar -b $(BUILDNAME)

clean:
	rm -rf build/agents

distclean:
	rm -rf build

.PHONY: all shar clean distclean
