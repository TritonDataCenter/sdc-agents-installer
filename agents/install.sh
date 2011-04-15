#!/bin/bash

set -e
set -o xtrace

TMP=/var/tmp
AGENTS="$(ls *.tgz)"
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

if [ ! -f $AGENTS_DIR/bin/agents-npm ] || $AGENTS_DIR/bin/agents-npm ls atropos | grep 'installed'; then
  # Install the actual atropos agent
  tar -zxvf atropos-*.tgz
  (cd atropos && ./bootstrap.sh "$AGENTS_DIR")
fi

# Install other agents, as if we were some npm-crazed honey badger.

for tarball in $AGENTS; do
  if $AGENTS_DIR/bin/agents-npm ls `echo $tarball | cut -f1 -d '.'` | grep 'installed'; then
    continue
  fi
    case "$tarball" in
        atropos-*.tgz)
            ;;
        *)
            npm-install "./$tarball"
            ;;
    esac
done

exit 0
