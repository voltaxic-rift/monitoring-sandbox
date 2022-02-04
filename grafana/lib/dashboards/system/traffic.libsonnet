local grafana = import 'grafonnet/grafana.libsonnet';

local target(traffic_measurement) = 
  grafana.influxdb.target(
    alias=traffic_measurement,
    measurement=traffic_measurement,
    fill='linear',
  )
  .selectField('value')
  .addConverter(type='mean')
  .addConverter(type='difference')
  .where('sensu_entity_name', '=~', '/^$entity$/', 'AND')
  .where('interface', '=~', '/^$interface$/', 'AND');

grafana.graphPanel.new(
  title='Traffic ($entity, $interface)',
  repeat='entity',
  nullPointMode='null as zero',
)
.addTarget(target('bytes_recv'))
.addTarget(target('bytes_sent'))
.addTarget(target('drop_in'))
.addTarget(target('drop_out'))
.addTarget(target('err_in'))
.addTarget(target('err_out'))
.addTarget(target('packets_recv'))
.addTarget(target('packets_out'))
