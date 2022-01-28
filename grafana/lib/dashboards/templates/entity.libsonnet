local grafana = import 'grafonnet/grafana.libsonnet';

grafana.template.new(
  name='entity',
  datasource='influxdb_sensu',
  query='show tag values from "system-check" with key="sensu_entity_name"',
  multi=true,
  refresh='load',
)
