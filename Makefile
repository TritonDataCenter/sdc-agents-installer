
ifeq ($(BUILDNAME),)
	BUILDNAME=master
endif

all: shar

# A shar of the "upgrade" agents, i.e. the 6.5 agents used for upgrading
# on 6.5 CNs during the transition to SDC7.
upgradeshar:
	./mk-agents-shar -b release-20110901-upgrade \
		agents-upgrade/provisioner-v2 \
		agents-upgrade/zonetracker-v2 \
		agents-upgrade/heartbeater \
		agents-upgrade/metadata

shar:
	./mk-agents-shar -b $(BUILDNAME)

clean:
	rm -rf build/agents

distclean:
	rm -rf build

.PHONY: all shar clean distclean
