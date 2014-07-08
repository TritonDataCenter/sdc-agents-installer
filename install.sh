#!/bin/bash

set -e
set -o xtrace

TMP=/var/tmp
AGENTS="$(ls *.tgz *.tar.gz *.tar.bz2 || /bin/true)"
AGENTS_DIR=/opt/smartdc/agents
export PATH="$PATH:$AGENTS_DIR/bin"

export PATH=$AGENTS_DIR/modules/.npm/agents_core/active/package/local/bin:$PATH

SDC_CONFIG=/lib/sdc/config.sh

if [ -x "$SDC_CONFIG" ]; then
  source $SDC_CONFIG
  load_sdc_config
  load_sdc_sysinfo
fi

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

cleanup-existing() {
  if [ -f "$AGENTS_DIR/bin/agents-npm" ] && agents-npm --no-registry ls atropos | grep 'installed'; then
    cleanup-lime
  elif [ -f "$AGENTS_DIR/bin/agents-npm" ]; then
    cleanup-npm-agents
  #elif [ -f "$AGENTS_DIR/bin/apm" ]; then
    # cleanup-apm
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

setup_config_agent() {
    local sapi_url=${CONFIG_sapi_domain}
    local prefix=AGENTS_DIR/lib/node_modules/config-agent
    local tmpfile=/tmp/agent.$$.xml

    sed -e "s#@@PREFIX@@#${prefix}#g" \
        ${prefix}/smf/manifests/config-agent.xml > ${tmpfile}
    mv ${tmpfile} ${prefix}/smf/manifests/config-agent.xml

    mkdir -p ${prefix}/etc
    local file=${prefix}/etc/config.json
    cat >${file} <<EOF
{
    "logLevel": "info",
    "pollInterval": 15000,
    "sapi": {
        "url": "${sapi_url}"
    }
}
EOF

  # CONFIG_AGENT_LOCAL_MANIFESTS_DIRS=/opt/smartdc/$role
  # Caller of setup.common can set 'CONFIG_AGENT_LOCAL_MANIFESTS_DIRS'
  # to have config-agent use local manifests.
  # if [[ -n "${CONFIG_AGENT_LOCAL_MANIFESTS_DIRS}" ]]; then
  #   for dir in ${CONFIG_AGENT_LOCAL_MANIFESTS_DIRS}; do
  #     local tmpfile=/tmp/add_dir.$$.json
  #     cat ${file} | json -e "
  #       this.localManifestDirs = this.localManifestDirs || [];
  #       this.localManifestDirs.push('$dir');
  #       " >${tmpfile}
  #     mv ${tmpfile} ${file}
  #   done
  # fi

  svccfg import ${prefix}/smf/manifests/config-agent.xml
  svcadm enable config-agent
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
setup_config_agent

exit 0
