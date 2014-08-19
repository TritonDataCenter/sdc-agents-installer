TOP=$(shell pwd)
_AWK := $(shell (which gawk >/dev/null && echo gawk) \
	|| (which nawk >/dev/null && echo nawk) \
	|| echo awk)
BRANCH := $(shell git symbolic-ref HEAD | $(_AWK) -F/ '{print $$3}')
ifeq ($(TIMESTAMP),)
	TIMESTAMP := $(shell date -u "+%Y%m%dT%H%M%SZ")
endif
_GITDESCRIBE := g$(shell git describe --all --long --dirty | $(_AWK) -F'-g' '{print $$NF}')
STAMP := $(BRANCH)-$(TIMESTAMP)-$(_GITDESCRIBE)

ifeq ($(BUILDNAME),)
	BUILDNAME=master
endif

TMPDIR          := /tmp/$(STAMP)
NAME		:= agentsshar
ifeq ($(shell uname -s),SunOS)
	TAR     ?= gtar
else
	TAR     ?= tar
endif


RELEASE_FILE := $(shell basename `ls $(TOP)/build/agents-*.sh | head -n 1`)

RELEASE_MANIFEST := $(NAME).imgmanifest;

all: shar manifest

deps:
	npm install

# A shar of the "upgrade" agents, i.e. the 6.5 agents used for upgrading
# on 6.5 CNs during the transition to SDC7.
upgradeshar: deps
	./mk-agents-shar -b release-20110901-upgrade \
		agents-upgrade/provisioner-v2 \
		agents-upgrade/zonetracker-v2 \
		agents-upgrade/heartbeater \
		agents-upgrade/metadata

manifest:
	mkdir -p $(TMPDIR)/$(NAME)
	uuid -v4 > $(TMPDIR)/$(NAME)/image_uuid
	cat $(TOP)/manifest.tmpl | sed \
		-e "s/UUID/$$(cat $(TMPDIR)/$(NAME)/image_uuid)/" \
		-e "s/NAME/$$(json name < $(TOP)/package.json)/" \
		-e "s/VERSION/1/" \
		-e "s/BUILDSTAMP/$(STAMP)/" \
		-e "s/SIZE/$$(stat --printf="%s" $(TOP)/build/$(RELEASE_FILE))/" \
		-e "s/SHA/$$(openssl sha1 $(TOP)/build/$(RELEASE_FILE) \
		    | cut -d ' ' -f2)/" \
		> $(TOP)/$(RELEASE_MANIFEST)

shar: deps
	./mk-agents-shar -b $(BUILDNAME)

clean:
	rm -rf build/agents

distclean:
	rm -rf build

.PHONY: all shar clean distclean deps
