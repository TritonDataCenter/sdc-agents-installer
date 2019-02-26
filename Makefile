#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2019, Joyent, Inc.
#

ENGBLD_REQUIRE := $(shell git submodule update --init deps/eng)
include ./deps/eng/tools/mk/Makefile.defs
TOP ?= $(error Unable to access eng.git submodule Makefiles.)

NAME = agentsshar

ifeq ($(BUILDNAME),)
    BUILDNAME=master
endif

CLEAN_FILES += build/agents

all: shar

deps:
	PATH=/opt/tools/bin:$(PATH) /opt/tools/bin/npm install

shar: deps
	PATH=/opt/tools/bin:$(PATH) ./mk-agents-shar -b $(BUILDNAME)

publish: shar
	mkdir -p $(ENGBLD_BITS_DIR)/$(NAME)
	cp build/agents-*.manifest \
		build/agents-*.sh \
		build/agents-*.md5sum \
		$(ENGBLD_BITS_DIR)/$(NAME)

.PHONY: all shar publish clean distclean deps

include ./deps/eng/tools/mk/Makefile.targ
