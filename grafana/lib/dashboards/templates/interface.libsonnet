local grafana = import 'grafonnet/grafana.libsonnet';

grafana.template.new(
  name='interface',
  datasource='influxdb_sensu',
  query='show tag values from "packets_sent" with key="interface" where sensu_entity_name =~ /^$entity$/',
  multi=true,
  refresh='load',
)
