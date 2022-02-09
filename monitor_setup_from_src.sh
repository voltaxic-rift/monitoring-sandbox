#!/bin/bash

set -eux

# Build Sensu Go
dnf install -y epel-release
dnf install -y golang
curl -LO https://github.com/sensu/sensu-go/archive/refs/tags/v6.6.5.tar.gz
tar zxvf v6.6.5.tar.gz
pushd sensu-go-6.6.5/
  export GO111MODULE=on
  export GOPROXY='https://proxy.golang.org'
  export GOOS=linux
  export GOARCH=amd64
  go build -o bin/sensu-agent ./cmd/sensu-agent
  go build -o bin/sensu-backend ./cmd/sensu-backend
  go build -o bin/sensuctl ./cmd/sensuctl
  mv bin/sensu-backend /usr/sbin/
  restorecon /usr/sbin/sensu-backend
  mv bin/sensuctl /usr/bin/
  restorecon /usr/bin/sensuctl
  cp bin/sensu-agent /usr/sbin/
  restorecon /usr/sbin/sensu-agent
  \mv -f bin/sensu-agent /vagrant/
  rm -rf bin/
popd

# Setup Sensu Go Backend
groupadd -r sensu
useradd -r -g sensu -d /opt/sensu -s /bin/false -c "Sensu Monitoring Framework" sensu

mkdir -p /var/cache/sensu/sensu-backend /var/lib/sensu/sensu-backend /var/log/sensu /var/run/sensu /etc/sensu
chown sensu:sensu /var/cache/sensu/sensu-backend
chown sensu:sensu /var/lib/sensu/sensu-backend
chown sensu:sensu /var/log/sensu
chown sensu:sensu /var/run/sensu

cat << 'EOS' > /lib/systemd/system/sensu-backend.service
[Unit]
Description=The Sensu Backend service.
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=sensu
Group=sensu
# Load env vars from /etc/default/ and /etc/sysconfig/ if they exist.
# Prefixing the path with '-' makes it try to load, but if the file doesn't
# exist, it continues onward.
EnvironmentFile=-/etc/default/sensu-backend
EnvironmentFile=-/etc/sysconfig/sensu-backend
LimitNOFILE=65535
ExecStart=/usr/sbin/sensu-backend start -c /etc/sensu/backend.yml
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
WorkingDirectory=/

[Install]
WantedBy=multi-user.target
EOS
chmod 0644 /lib/systemd/system/sensu-backend.service

cp /vagrant/backend.yml /etc/sensu/
systemctl daemon-reload
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
for asset_path in `find /vagrant/sensu/assets/src/* -maxdepth 0 -type d`; do
  pushd $asset_path
    ASSET_TARBALL=$(basename $asset_path).tar.gz
    CGO_ENABLED=0 go build -ldflags='-s -w' -o bin/
    tar -c --mtime='1970-01-01' --owner=0 --group=0 --remove-files bin/ | gzip -n > ../../dist/${ASSET_TARBALL}
    shasum -a 512 ../../dist/${ASSET_TARBALL} | awk '{print $1}' > ../../dist/${ASSET_TARBALL}.sha512
  popd
done

# Hosting Assets
dnf install -y https://download.copr.fedorainfracloud.org/results/@caddy/caddy/epel-8-x86_64/02938531-caddy/caddy-2.4.6-1.el8.x86_64.rpm
\cp -f /vagrant/Caddyfile /etc/caddy/Caddyfile
systemctl enable --now caddy

# Create Sensu Resources
sensuctl create -r -f /vagrant/sensu/namespaces/default

# Setup Sensu Go Agent
mkdir -p /var/cache/sensu/sensu-agent /var/lib/sensu/sensu-agent
chown sensu:sensu /var/cache/sensu/sensu-agent
chown sensu:sensu /var/lib/sensu/sensu-agent

cat << 'EOS' > /lib/systemd/system/sensu-agent.service
[Unit]
Description=The Sensu Agent process.
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=sensu
Group=sensu
# Load env vars from /etc/default/ and /etc/sysconfig/ if they exist.
# Prefixing the path with '-' makes it try to load, but if the file doesn't
# exist, it continues onward.
EnvironmentFile=-/etc/default/sensu-agent
EnvironmentFile=-/etc/sysconfig/sensu-agent
LimitNOFILE=65535
ExecStart=/usr/sbin/sensu-agent start -c /etc/sensu/agent.yml
Restart=always
WorkingDirectory=/

[Install]
WantedBy=multi-user.target
EOS
chmod 0644 /lib/systemd/system/sensu-agent.service

cp /vagrant/agent.yml /etc/sensu/
systemctl daemon-reload
systemctl enable --now sensu-agent
