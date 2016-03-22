#!/bin/bash
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2015, Joyent, Inc.
#

set -e
set -o xtrace

TMP=/var/tmp
AGENTS="$(ls *.tgz *.tar.gz *.tar.bz2 || /bin/true)"
AGENTS_DIR=/opt/smartdc/agents
export PATH="$PATH:$AGENTS_DIR/bin"

export PATH=$AGENTS_DIR/modules/.npm/agents_core/active/package/local/bin:$PATH

message() {
  echo "==> $*" >&2
}

agents-install() {
  WHAT=$1
  $INSTALLER install "$WHAT"
}

rm-agent-dirs() {
  for dir in $(ls "$AGENTS_DIR"); do
    case "$dir" in
      db|smf)
        continue
        ;;
      *)
        rm -fr $AGENTS_DIR/$dir
        ;;
    esac
  done
}

cleanup-lime() {
  message "Upgrading agents from Lime-era release."
  TOREMOVE="$(agents-npm --no-registry ls installed | grep -v '^atropos@') atropos"
  for agent in "$TOREMOVE"; do
    log "Attempting to uninstall $agent"
    agents-npm uninstall $agent;
  done

  rm-agent-dirs
}

cleanup-npm-agents() {
  message "Updating existing agents install."
  TOREMOVE="$(agents-npm --no-registry ls installed | awk '{ print $1 }')"
  for agent in "$TOREMOVE"; do
    if (echo "$agent" | grep '^atropos@'); then
      continue
    fi

    agents-npm uninstall $agent;
  done

  rm-agent-dirs
}

cleanup-apm() {
    # no_rabbit is now the best rabbit (AGENT-950)
    message "Removing agents from rabbit era."
    if [[ -d /opt/smartdc/agents/lib/node_modules/provisioner ]]; then
        ${AGENTS_DIR}/bin/apm uninstall provisioner
    fi
    if [[ -d /opt/smartdc/agents/lib/node_modules/heartbeater ]]; then
        ${AGENTS_DIR}/bin/apm uninstall heartbeater
    fi
}

cleanup-existing() {
  if [ -f "$AGENTS_DIR/bin/agents-npm" ] && agents-npm --no-registry ls atropos | grep 'installed'; then
    cleanup-lime
  elif [ -f "$AGENTS_DIR/bin/agents-npm" ]; then
    cleanup-npm-agents
  elif [ -f "$AGENTS_DIR/bin/apm" ]; then
    cleanup-apm
  fi
}

bootstrap() {
  # Run the bootstrap script
  if [ ! -f $AGENTS_DIR/bin/agents-npm ] || $AGENTS_DIR/bin/agents-npm --no-registry ls agents_core | awk '{ print $1 }' | grep 'installed'; then
    # Install the actual atropos agent
    tar -zxvf agents_core-*.tgz
    (cd agents_core && ./bootstrap/bootstrap.sh "$AGENTS_DIR")
  fi
}

install-agents() {
  # Install the agents locally
  for tarball in $AGENTS; do
    case "$tarball" in
      agents_core-*.tgz)
        ;;
      *)
        agents-install "./$tarball"
        ;;
    esac
  done
}

restart-cn-agents() {
  svcadm restart cn-agent
}

# The 6.5 upgrade agent shar does not contain the agents_core-* tarball
if [ -z "`ls agents_core-*.tgz 2>/dev/null`" ]; then
    # This is the installer for the 6.5 upgrade agents
    INSTALLER=agents-npm
else
    INSTALLER=apm
    cleanup-existing
    bootstrap
fi

install-agents

# restart cn-agent to force an update of installed agent versions
restart-cn-agents

exit 0
