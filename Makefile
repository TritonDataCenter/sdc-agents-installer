
ifeq ($(BUILDNAME),)
	BUILDNAME=master
endif

all: shar

# Build a shar with just the agents needed for upgrades on 6.5 CNs
# during the transition to SDC 7. We are abusing the args to
# mk-agents-shar a little bit because the MG dir structure for
# uploaded agents is different that before.
upgradeshar:
	./mk-agents-shar -b "release-20110901-upgrade" \
		-d "https://guest:GrojhykMid@bits.joyent.us/builds/agents-upgrade/release-20110901-upgrade-latest" \
		agents-upgrade/provisioner-v2 \
		agents-upgrade/zonetracker-v2 \
		agents-upgrade/heartbeater \
		agents-upgrade/metadata

shar:
	./mk-agents-shar -b $(BUILDNAME)

hvmshar:
	./mk-agents-shar -b hvm \
		atropos/atropos provisioner/provisioner heartbeater/heartbeater

clean:
	rm -rf build/agents

distclean:
	rm -rf build

.PHONY: all shar hvmshar clean distclean
