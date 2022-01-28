local grr = import 'grizzly/grizzly.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local templates = import 'templates.libsonnet';
local panels = {
  cpu_usage:: import 'system/cpu_usage.libsonnet',
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
  .addPanel(panels.cpu_usage, gridPos={h: 8})
)
