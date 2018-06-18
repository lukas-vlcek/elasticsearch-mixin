local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
// local row = grafana.row;
// local prometheus = grafana.prometheus;
// local template = grafana.template;
// local graphPanel = grafana.graphPanel;
// local promgrafonnet = import '../lib/promgrafonnet/promgrafonnet.libsonnet';
// local numbersinglestat = promgrafonnet.numbersinglestat;
// local gauge = promgrafonnet.gauge;

{
  grafanaDashboards+:: {
    'elasticsearch.json':
      dashboard.new('Elasticsearch', time_from='now-3h'),
  },
}
