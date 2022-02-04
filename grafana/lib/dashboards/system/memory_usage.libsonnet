local grafana = import 'grafonnet/grafana.libsonnet';

local target(memory_measurement) = 
  grafana.influxdb.target(
    alias=memory_measurement,
    measurement=memory_measurement,
    fill='linear',
  )
  .selectField('value')
  .addConverter(type='mean')
  .where('sensu_entity_name', '=~', '/^$entity$/', 'AND');

grafana.graphPanel.new(
  title='Memory Usage ($entity)',
  repeat='entity',
  nullPointMode='null as zero',
)
.addTarget(target('mem_available'))
.addTarget(target('mem_free'))
.addTarget(target('mem_total'))
.addTarget(target('mem_used'))
.addTarget(target('swap_free'))
.addTarget(target('swap_total'))
.addTarget(target('swap_used'))
