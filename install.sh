#!/bin/bash

set -e
set -o xtrace

TMP=/var/tmp
AGENTS="$(ls *.tgz *.tar.gz *.tar.bz2 || /bin/true)"
AGENTS_DIR=/opt/smartdc/agents
export PATH="$PATH:$AGENTS_DIR/bin"

export PATH=$AGENTS_DIR/modules/.npm/agents_core/active/package/local/bin:$PATH

source /lib/sdc/config.sh
load_sdc_config
load_sdc_sysinfo

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
    local prefix=$AGENTS_DIR/lib/node_modules/config-agent
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

  # svccfg import ${prefix}/smf/manifests/config-agent.xml
  # svcadm enable config-agent
}

# "sapi_adopt" means adding an agent "instance" record to SAPI's DB
# $1: service_name
# $2: instance_uuid
function sapi_adopt()
{
  local service_name=$1
  local sapi_url=${CONFIG_sapi_domain}

  local service_uuid=""
  local i=0
  while [[ -z ${service_uuid} && ${i} -lt 48 ]]; do
      service_uuid=$(curl ${sapi_url}/services?name=${service_name}\
          -sS -H accept:application/json | json -Ha uuid)
      if [[ -z ${service_uuid} ]]; then
          echo "Unable to get server_uuid from sapi yet.  Sleeping..."
          sleep 5
      fi
      i=$((${i} + 1))
  done
  [[ -n ${service_uuid} ]] || \
      fatal "Unable to get service_uuid for role ${service_name} from SAPI"

  uuid=$2

  i=0
  while [[ -z ${sapi_instance} && ${i} -lt 48 ]]; do
      sapi_instance=$(curl ${sapi_url}/instances -sS -X POST \
          -H content-type:application/json \
          -d "{ \"service_uuid\" : \"${service_uuid}\", \"uuid\" : \"${uuid}\" }" \
          | json -H uuid)
      if [[ -z ${sapi_instance} ]]; then
          echo "Unable to adopt ${service_name} ${uuid} into sapi yet.  Sleeping..."
          sleep 5
      fi
      i=$((${i} + 1))
  done

  [[ -n ${sapi_instance} ]] || fatal "Unable to adopt ${uuid} into SAPI"
  echo "Adopted service ${service_name} to instance ${uuid}"
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
