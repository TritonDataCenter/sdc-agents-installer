
ifeq ($(BUILDNAME),)
	BUILDNAME=master
endif

all: shar

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
