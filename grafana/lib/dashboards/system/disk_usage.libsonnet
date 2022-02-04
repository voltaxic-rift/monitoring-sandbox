local grafana = import 'grafonnet/grafana.libsonnet';

local target(disk_measurement) = 
  grafana.influxdb.target(
    alias=disk_measurement,
    measurement='disk_'+ disk_measurement,
    fill='previous',
  )
  .selectField('value')
  .addConverter(type='mean')
  .where('sensu_entity_name', '=~', '/^$entity$/', 'AND')
  .where('mountpoint', '=~', '/^$disk$/', 'AND');

grafana.graphPanel.new(
  title='Disk Usage ($entity, $disk)',
  repeat='entity',
  nullPointMode='null as zero',
  legend_alignAsTable=true,
  legend_current=true,
  legend_avg=true,
  legend_min=true,
  legend_max=true,
  legend_rightSide=true,
  legend_values=true,
  format='bytes',
)
.addTarget(target('critical'))
.addTarget(target('warning'))
.addTarget(target('free_bytes'))
.addTarget(target('total_bytes'))
.addTarget(target('used_bytes'))
