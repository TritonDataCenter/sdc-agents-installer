<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2014, Joyent, Inc.
-->

# SDC Agents Installer

This repository is part of the SmartDataCenter (SDC) project. For
contribution guidelines, issues, and general documentation, visit the
[main SDC project](http://github.com/joyent/sdc).

Agents Installer automates the process of building a self-extracting
executable for installing [agent services](https://github.com/joyent/sdc/blob/master/docs/glossary.md#service).


## Agents shar Packaging

The main function of the tools in this repo is to produce shell scripts which
when run will unpack a number of archives for agent services and install
them. At build time, select the agents to package by adding them to
agents.json.

The product of this process is called an  "agentsshar" is used to install and
upgrade agents in SDC.

See the Makefile for typical build targets.

The main 'mk-agents-shar' script presumes a [Mountain Gorilla style directory
structure](https://github.com/joyent/mountain-gorilla/blob/master/docs/index.md#bits-directory-structure).


## Repository

    Makefile
    package.json    npm module info (holds the project version)
    mk-agents-shar  executable which creates self-extracting script
    manifest.tmpl   image manifest for uploading to updates.joyent.com
    README.md
    install.sh      file run after installer unpacks all files
    agents.json     mapping of agents/repos/packages


## License

SDC Agents Installer is licensed under the
[Mozilla Public License version 2.0](http://mozilla.org/MPL/2.0/).
