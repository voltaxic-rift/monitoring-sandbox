local grafana = import 'grafonnet/grafana.libsonnet';

local target(cpu_measurement) = 
  grafana.influxdb.target(
    alias=cpu_measurement,
    measurement='system_cpu_' + cpu_measurement,
    fill='linear',
  )
  .selectField('value')
  .addConverter(type='mean')
  .where('sensu_entity_name', '=~', '/^$entity$/', 'AND')
  .where('cpu', '=', 'cpu-total');

grafana.graphPanel.new(
  title='CPU Usage ($entity)',
  repeat='entity',
  nullPointMode='null as zero',
  stack=true,
)
.addTarget(target('idle'))
.addTarget(target('user'))
.addTarget(target('system'))
.addTarget(target('nice'))
.addTarget(target('iowait'))
.addTarget(target('irq'))
.addTarget(target('sortirq'))
.addTarget(target('stolen'))
.addTarget(target('guest'))
.addTarget(target('guest_nice'))
