#!/bin/bash -e

TMPFILE=$(mktemp)
PWD=$(pwd)
CONSUL_VERSION="1.9.6"
CONSUL_TEMPLATE_VERSION="0.26.0"

mkdir -p /opt/consul/data
mkdir -p /opt/consul/config
yum install -y jq git dnsmasq
useradd --system consul

cp /tmp/consul-server.service /etc/systemd/system/consul-server.service
cp /tmp/dnsmasq-consul.conf /etc/dnsmasq.d/consul
cp /tmp/consul_config.hcl /opt/consul/config/server.hcl

#Load Linux utils
until git clone https://github.com/aws-quickstart/quickstart-linux-utilities.git ; do echo "Retrying"; done
cd quickstart-linux-utilities && source quickstart-cfn-tools.source
# Prep operating systems
qs_update-os || qs_err
qs_bootstrap_pip || qs_err
qs_aws-cfn-bootstrap || qs_err

declare -A ARCH_MAP
ARCH_MAP[x86_64]=amd64
ARCH_MAP[aarch64]=arm64

ARCH="${ARCH_MAP[$(uname -p)]}"

curl --output "${TMPFILE}" -q https://releases.hashicorp.com/consul/"${CONSUL_VERSION}"/consul_"${CONSUL_VERSION}"_linux_"${ARCH}".zip
unzip -d /usr/bin "${TMPFILE}"
rm "${TMPFILE}"

curl --output "${TMPFILE}" -q https://releases.hashicorp.com/consul-template/"${CONSUL_TEMPLATE_VERSION}"/consul-template_"${CONSUL_TEMPLATE_VERSION}"_linux_"${ARCH}".zip
unzip -d /usr/bin "${TMPFILE}"
rm "${TMPFILE}"

chown -R consul:consul /opt/consul
systemctl daemon-reload
systemctl restart dnsmasq
