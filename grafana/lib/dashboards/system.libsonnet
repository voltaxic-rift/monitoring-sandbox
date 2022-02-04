local grr = import 'grizzly/grizzly.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local templates = import 'templates.libsonnet';
local panels = {
  cpu_usage:: import 'system/cpu_usage.libsonnet',
  memory_usage:: import 'system/memory_usage.libsonnet',
  traffic:: import 'system/traffic.libsonnet',
  disk_usage:: import 'system/disk_usage.libsonnet',
};

grr.resource.new(
  'Dashboard',
  'system'
) +
grr.resource.withSpec(
  grafana.dashboard.new(
    title='System',
    editable=true,
  )
  .addTemplate(templates.entity)
  .addTemplate(templates.interface)
  .addTemplate(templates.disk)
  .addPanel(panels.cpu_usage, gridPos={h: 8})
  .addPanel(panels.memory_usage, gridPos={h: 8})
  .addPanel(panels.traffic, gridPos={h: 8})
  .addPanel(panels.disk_usage, gridPos={h: 8})
)
