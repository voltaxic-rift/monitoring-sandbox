local grafana = import 'grafonnet/grafana.libsonnet';

grafana.template.new(
  name='disk',
  datasource='influxdb_sensu',
  query='show tag values from "disk_percent_usage" with key="mountpoint" where sensu_entity_name =~ /^$entity$/',
  multi=true,
  refresh='load',
)
