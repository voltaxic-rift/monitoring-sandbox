#!/bin/bash

set -eux

dnf install -y https://packagecloud.io/sensu/stable/packages/el/8/sensu-go-agent-6.6.4-5671.x86_64.rpm/download.rpm
cp /vagrant/agent.yml /etc/sensu/
systemctl enable --now sensu-agent
