<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2014, Joyent, Inc.
-->

# sdc-agents-installer

This repository is part of the Joyent SmartDataCenter project (SDC).  For
contribution guidelines, issues, and general documentation, visit the main
[SDC](http://github.com/joyent/sdc) project page.

sdc-agents-installer automates the process of building a self-extracting
executable for installing agent services.


# Agents shar packaging

The main function of the tools in this repo is to produce shell scripts which
when run will unpack a number of archives for agent services and install
them. At build time, select the agents to package by adding them to
agents.json.

The product of this process is called an  "agentsshar" is used to install and
upgrade agents in SDC.

See the Makefile for typical build targets.

The main 'mk-agents-shar' script presumes a MG-style directory structure
(https://mo.joyent.com/docs/mg/master/#bits-directory-structure).


# Development

    git clone git@github.com:joyent/sdc-agents-installer.git
    cd sdc-imgapi
    git submodule update --init


# Repository

    Makefile
    package.json    npm module info (holds the project version)
    mk-agents-shar  executable which creates self-extracting script
    manifest.tmpl   image manifest for uploading to updates.joyent.com
    README.md
    install.sh      file run after installer unpacks all files
    agents.json     mapping of agents/repos/packages
