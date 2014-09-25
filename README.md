<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2014, Joyent, Inc.
-->

# Agents Installer Creator

Repository: <git@github.com:joyent/sdc-agents-installer.git>
Browsing: <https://mo.joyent.com/agents-installer>
Who: Orlando Vazquez
Docs: <https://mo.joyent.com/docs/agents-installer>
Tickets/bugs: <https://devhub.joyent.com/jira/browse/AGENT>


# Agents shar packaging

This repo will build a shar script which is a self contained script that
includes SDC agents (by default all of them in agents.json) and a small
script to unpack this directory and run the install.sh script within.  This
so called "agentsshar" is used to install and upgrade agents in SDC.

See the Makefile for typical build targets.

The main 'mk-agents-shar' script presumes a MG-style directory structure
(https://mo.joyent.com/docs/mg/master/#bits-directory-structure).


# Repository

    Makefile
    package.json    npm module info (holds the project version)
    mk-agents-shar  executable which creates self-extracting script
    manifest.tmpl   image manifest for uploading to updates.joyent.com
    README.md
    install.sh      file run after installer unpacks all files
    agents.json     mapping of agents/repos/packages
