#!/bin/bash

set -e

TMP=/var/tmp
AGENTS="atropos.tgz
        provisioner.tgz
        heartbeater.tgz
        cabase.tar.gz
        cainstsvc.tar.gz
        dataset_manager.tgz
        zonetracker.tgz"
AGENTS_DIR=/opt/smartdc/agents

# Check if we're in a COAL environment.
is-coal() {
    if [ "$COAL" != "0" -a "$COAL" != "false" ]; then
        return 0
    else
        return 1
    fi
}

npm-install() {
  WHAT=$1
  PATH=$AGENTS_DIR/modules/.npm/atropos/active/package/local/bin:$PATH \
      $AGENTS_DIR/bin/agents-npm --no-registry install "$WHAT"
}

if is-coal; then
    rabbitmq=$(grep '^rabbitmq=' /etc/headnode.config 2>/dev/null || bootparams | grep '^rabbitmq=' | cut -d'=' -f2-)
    amqp_user=$(echo ${rabbitmq} | cut -d':' -f1 | cut -d'=' -f2)
    amqp_pass=$(echo ${rabbitmq} | cut -d':' -f2)
    amqp_host=$(echo ${rabbitmq} | cut -d':' -f3)
fi

# Install the actual atropos agent
tar -zxvf atropos.tgz
(cd atropos && ./bootstrap.sh "$AGENTS_DIR")

if is-coal; then
    if [[ -f $AGENTS_DIR/etc/atropos.ini ]]; then
        echo "host = ${amqp_host}" >> $AGENTS_DIR/etc/atropos.ini
    fi
fi

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
            if is-coal; then
                if [[ -f $AGENTS_DIR/etc/heartbeater.ini ]]; then
                    echo "host = ${amqp_host}" >> $AGENTS_DIR/etc/heartbeater.ini
                fi
            fi
            ;;

        *)
            npm-install "./$tarball"
            ;;
    esac
done

exit 0
