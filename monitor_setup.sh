#!/bin/bash

set -eux

# Sensu Go Backend
dnf install -y https://packagecloud.io/sensu/stable/packages/el/8/sensu-go-cli-6.6.4-5671.x86_64.rpm/download.rpm
dnf install -y https://packagecloud.io/sensu/stable/packages/el/8/sensu-go-backend-6.6.4-5671.x86_64.rpm/download.rpm
cp /vagrant/backend.yml /etc/sensu/
systemctl enable --now sensu-backend
export SENSU_BACKEND_CLUSTER_ADMIN_USERNAME=admin
export SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD=admin
sensu-backend init
sensuctl configure -n --username admin --password admin --namespace default --url 'http://localhost:8080'

# InfluxDB
dnf install -y https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10.x86_64.rpm
systemctl enable --now influxdb

# Grafana
dnf install -y https://dl.grafana.com/oss/release/grafana-8.3.4-1.x86_64.rpm
\cp -f /vagrant/grafana.ini /etc/grafana/grafana.ini
systemctl enable --now grafana-server

# Create InfluxDB Database
influx -execute 'create database sensu'

# Build Assets
dnf install -y golang
for asset_path in `find /vagrant/sensu/assets/src/* -maxdepth 0 -type d`; do
  pushd $asset_path
    ASSET_TARBALL=$(basename $asset_path).tar.gz
    CGO_ENABLED=0 go build -ldflags='-s -w' -o bin/
    tar cvzf ../../dist/${ASSET_TARBALL} --remove-files bin/
    sha512sum ../../dist/${ASSET_TARBALL} | awk '{print $1}' > ../../dist/${ASSET_TARBALL}.sha512
  popd
done

# Hosting Assets
dnf install -y https://download.copr.fedorainfracloud.org/results/@caddy/caddy/epel-8-x86_64/02938531-caddy/caddy-2.4.6-1.el8.x86_64.rpm
\cp -f /vagrant/Caddyfile /etc/caddy/Caddyfile
systemctl enable --now caddy

# checksum 検証切らせてくれ頼む
\cp -f /vagrant/check-disk-usage.yml.tmpl /vagrant/sensu/namespaces/default/checks/check-disk-usage.yml
sed -ri "s/( +sha512: ).+/\1$(cat /vagrant/sensu/assets/dist/check-disk-usage.tar.gz.sha512)/" /vagrant/sensu/namespaces/default/checks/check-disk-usage.yml

# Create Sensu Resources
sensuctl create -r -f /vagrant/sensu/namespaces/default

# Sensu Go Agent
dnf install -y https://packagecloud.io/sensu/stable/packages/el/8/sensu-go-agent-6.6.4-5671.x86_64.rpm/download.rpm
cp /vagrant/agent.yml /etc/sensu/
systemctl enable --now sensu-agent
