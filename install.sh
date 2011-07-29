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
}

npm-publish() {
    WHAT=$1
    if [ "$SYSINFO_Bootparam_headnode" == "true" ]; then
        $AGENTS_DIR/bin/agents-npm publish "$WHAT"
    fi
}

# Wait for the atropos zone couchdb instance to come up.

NPM_REGISTRY_ADDR=$CONFIG_atropos_admin_ip
NPM_REGISTRY_PORT=5984
REGISTRY_URL=http://$NPM_REGISTRY_ADDR:$NPM_REGISTRY_PORT/jsregistry/_design/app/_rewrite
SLEEP_PERIOD=10
SLEPT=0
MAX_SLEEP=300

while [[ $SLEPT -lt $MAX_SLEEP ]]; do
    if curl --silent --connect-timeout 5 $REGISTRY_URL; then
        echo "Registry $REGISTRY_URL was fine";
        break;
    else
        echo "Registry not yet up..."
    fi

    SLEPT=$(($SLEPT + $SLEEP_PERIOD))
    sleep 5
done

# Run the bootstrap script
if [ ! -f $AGENTS_DIR/bin/agents-npm ] || $AGENTS_DIR/bin/agents-npm ls atropos | grep 'installed'; then
  # Install the actual atropos agent
  tar -zxvf atropos-*.tgz
  (cd atropos && ./bootstrap.sh "$AGENTS_DIR")
fi

# Install the agents locally
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

# Publish the agents to the atropos npm registry.
for tarball in $AGENTS; do
  if $AGENTS_DIR/bin/agents-npm ls `echo $tarball | cut -f1 -d '.'` | grep 'installed'; then
    continue
  fi
    case "$tarball" in
        atropos-*.tgz)
            ;;
        *)
            npm-publish "./$tarball"
            ;;
    esac
done

exit 0
