#!/bin/bash

# Sensu Go Backend
dnf install -y https://packagecloud.io/sensu/stable/packages/el/8/sensu-go-cli-6.6.4-5671.x86_64.rpm/download.rpm
dnf install -y https://packagecloud.io/sensu/stable/packages/el/8/sensu-go-backend-6.6.4-5671.x86_64.rpm/download.rpm
cp /vagrant/backend.yml /etc/sensu/
systemctl enable --now sensu-backend
export SENSU_BACKEND_CLUSTER_ADMIN_USERNAME=admin
export SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD=admin
sensu-backend init
sensuctl configure -n --username admin --password admin --namespace default --url 'http://localhost:8080'

# Sensu Go Agent
dnf install -y https://packagecloud.io/sensu/stable/packages/el/8/sensu-go-agent-6.6.4-5671.x86_64.rpm/download.rpm
cp /vagrant/agent.yml /etc/sensu/
systemctl enable --now sensu-agent

# InfluxDB
dnf install -y https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10.x86_64.rpm
systemctl enable --now influxdb

# Grafana
dnf install -y https://dl.grafana.com/oss/release/grafana-8.3.4-1.x86_64.rpm
\cp -f /vagrant/grafana.ini /etc/grafana/grafana.ini
systemctl enable --now grafana-server
