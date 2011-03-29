#!/bin/bash

set -e
set -o xtrace

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

SDC_CONFIG=/lib/sdc/config.sh

if [ -x "$SDC_CONFIG" ]; then
    source $SDC_CONFIG
    load_sdc_config
    load_sdc_sysinfo
fi

npm-install() {
    WHAT=$1
    $AGENTS_DIR/bin/agents-npm --no-registry install "$WHAT"
    if [ "$SYSINFO_Bootparam_headnode" == "true" ]; then
        $AGENTS_DIR/bin/agents-npm publish "$WHAT"
    fi
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
