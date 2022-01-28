local grr = import 'grizzly/grizzly.libsonnet';

grr.resource.new('Datasource', 'influxdb_sensu') +
grr.resource.withSpec({
  access: 'proxy',
  basicAuth: false,
  basicAuthPassword: '',
  basicAuthUser: '',
  database: 'sensu',
  isDefault: true,
  jsonData: {},
  name: 'InfluxDB (Sensu)',
  orgId: 1,
  password: '',
  readOnly: false,
  secureJsonFields: {},
  type: 'influxdb',
  typeLogoUrl: '',
  uid: 'influxdb_sensu',
  url: 'http://localhost:8086',
  user: '',
  withCredentials: false,
})
