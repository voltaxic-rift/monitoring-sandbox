#!/bin/bash

echo "Resource Pruning..."
sensuctl prune checks,handlers,filters,mutators,assets,secrets/v1.Secret,roles,role-bindings,core/v2.HookConfig -r -f /vagrant/sensu/namespaces/default

echo "Resource Creating..."
sensuctl create -r -f /vagrant/sensu/namespaces/default
echo "Done"
