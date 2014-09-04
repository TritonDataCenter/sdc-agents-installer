#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2014, Joyent, Inc.
#

ifeq ($(BUILDNAME),)
    BUILDNAME=master
endif

all: shar

deps:
	npm install

shar: deps
	./mk-agents-shar -b $(BUILDNAME)

clean:
	rm -rf build/agents

distclean:
	rm -rf build

.PHONY: all shar clean distclean deps
