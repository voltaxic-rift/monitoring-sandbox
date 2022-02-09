#!/bin/bash

set -eux

cp /vagrant/sensu-agent /usr/sbin/
restorecon /usr/sbin/sensu-agent
