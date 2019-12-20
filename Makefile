#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright 2019 Joyent, Inc.
#

ENGBLD_REQUIRE := $(shell git submodule update --init deps/eng)
include ./deps/eng/tools/mk/Makefile.defs
TOP ?= $(error Unable to access eng.git submodule Makefiles.)

NAME = agentsshar

ifeq ($(BUILDNAME),)
    BUILDNAME=$(BRANCH)
else
	# Override BRANCH and STAMP so that the filename of the output
	# shar better describes its contents. The branch and `git describe`
	# of the sdc-agents-installer repo is computed by the mk-agents-shar
	# script. We do this here rather than just in mk-agents-shar so that
	# the directory name used by bits-upload.sh remains correct.
	#
	# This results in artifacts of the form:
	#
	# agents-<sdc-agents-installer branch>-<buildname separated by '-'><timestamp>-<githash>.manifest
	# agents-<sdc-agents-installer branch>-<buildname separated by '-'><timestamp>-<githash>.md5sum
	# agents-<sdc-agents-installer branch>-<buildname separated by '-'>-<timestamp>-<githash>.sh
	#
	# The BUILDNAME branches, which indicate the branches of agents to include
	# in the generated shar archive, are deduped, and in cases where the
	# sdc-agents-installer branch matches the only unique branch name from
	# BUILDNAME, we use only the <sdc-agents-installer branch> rather than the
	# hyphen-separated <sdc-agents-installer branch>-<buildname> value.
	#
	AGENTS_INSTALLER_BRANCH=$(shell git symbolic-ref HEAD | $(_AWK) -F/ '{print $$3}')
	BUNDLED_AGENTS_BRANCHES=$(shell for branch in $$BUILDNAME; do if [[ $$branch == $(AGENTS_INSTALLER_BRANCH) ]]; then continue; fi; echo $$branch; done | sort -u)
	ifneq ($(BUNDLED_AGENTS_BRANCHES),)
	    BRANCH=$(AGENTS_INSTALLER_BRANCH)-$(shell echo $(BUNDLED_AGENTS_BRANCHES) | sed -e 's/ /-/g')
	endif
	STAMP:=$(BRANCH)-$(TIMESTAMP)-$(_GITDESCRIBE)
endif

CLEAN_FILES += build/agents

all: shar

deps:
	PATH=/opt/tools/bin:$(PATH) /opt/tools/bin/npm install

shar: deps
	PATH=/opt/tools/bin:$(PATH) ./mk-agents-shar -b "$(BUILDNAME)" -B $(BRANCH)

publish: shar
	mkdir -p $(ENGBLD_BITS_DIR)/$(NAME)
	cp build/agents-*.manifest \
		build/agents-*.sh \
		build/agents-*.md5sum \
		$(ENGBLD_BITS_DIR)/$(NAME)

.PHONY: all shar publish clean distclean deps

include ./deps/eng/tools/mk/Makefile.targ
