local grafana = import 'grafonnet/grafana.libsonnet';

local target(cpu_measurement) = 
  grafana.influxdb.target(
    alias=cpu_measurement,
    measurement='cpu_' + cpu_measurement,
    fill='previous',
  )
  .selectField('value')
  .addConverter(type='mean')
  .where('sensu_entity_name', '=~', '/^$entity$/', 'AND');

grafana.graphPanel.new(
  title='CPU Usage ($entity)',
  repeat='entity',
  nullPointMode='null as zero',
  stack=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_avg=true,
  legend_min=true,
  legend_max=true,
  legend_rightSide=true,
  legend_values=true,
  percentage=true,
  format='percent',
  max=100,
)
.addTarget(target('idle'))
.addTarget(target('user'))
.addTarget(target('system'))
.addTarget(target('nice'))
.addTarget(target('iowait'))
.addTarget(target('irq'))
.addTarget(target('softirq'))
.addTarget(target('steal'))
.addTarget(target('guest'))
.addTarget(target('guestnice'))
