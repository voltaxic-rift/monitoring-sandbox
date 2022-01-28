
local datasources = import 'datasources.libsonnet';
local dashboards = import 'dashboards.libsonnet';

{
  datasources: [
    datasources.influxdb_sensu,
  ],
  dashboards: [
    dashboards.system,
  ],
}
