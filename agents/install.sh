#!/bin/bash

set -e
set -o xtrace

TMP=/var/tmp
AGENTS="$(ls *.tgz)"
AGENTS_DIR=/opt/smartdc/agents

export PATH=$AGENTS_DIR/modules/.npm/agents_core/active/package/local/bin:$PATH

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

# Run the bootstrap script
if [ ! -f $AGENTS_DIR/bin/agents-npm ] || $AGENTS_DIR/bin/agents-npm --no-registry ls agents_core | grep 'installed'; then
  # Install the actual atropos agent
  tar -zxvf agents_core-*.tgz
  (cd agents_core && ./bootstrap/bootstrap.sh "$AGENTS_DIR")
fi

# Install the agents locally
for tarball in $AGENTS; do
    case "$tarball" in
        agents_core-*.tgz)
            ;;
        *)
            npm-install "./$tarball"
            ;;
    esac
done

exit 0
