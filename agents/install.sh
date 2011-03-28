#!/bin/bash

set -e

TMP=/var/tmp
AGENTS="atropos.tgz
        provisioner.tgz
        heartbeater.tgz
        cabase.tar.gz
        cainstsvc.tar.gz
        dataset_manager.tgz
        smart-login.tgz
        zonetracker.tgz"
AGENTS_DIR=/opt/smartdc/agents

export PATH=$AGENTS_DIR/modules/.npm/atropos/active/package/local/bin:$PATH

npm-install() {
  $AGENTS_DIR/bin/agents-npm --no-registry install "$WHAT"
  $AGENTS_DIR/bin/agents-npm --no-registry publish "$WHAT"
}

# Install the actual atropos agent
tar -zxvf atropos.tgz
(cd atropos && ./bootstrap.sh "$AGENTS_DIR")

# Install other agents, as if we were some npm-crazed honey badger.

for tarball in $AGENTS; do
    case "$tarball" in
        atropos.tgz)
            ;;

        provisioner.tgz)
            npm-install "./$tarball"
            ;;

        heartbeater.tgz)
            npm-install "./$tarball"
            ;;

        *)
            npm-install "./$tarball"
            ;;
    esac
done

exit 0
