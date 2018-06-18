local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local promgrafonnet = import '../lib/promgrafonnet/promgrafonnet.libsonnet';
local numbersinglestat = promgrafonnet.numbersinglestat;
local gauge = promgrafonnet.gauge;

{
  grafanaDashboards+:: {
    'logging-elasticsearch.json':

      local replicasGraph =
        graphPanel.new(
          'Replicas',
          datasource='$datasource',
        );

      local replicasRow = row.new()
                          .addPanel(replicasGraph);

      dashboard.new('Elasticsearch', time_from='now-3h')
      .addTemplate(
        {
          current: {
            text: 'Prometheus',
            value: 'Prometheus',
          },
          hide: 0,
          label: null,
          name: 'datasource',
          options: [],
          query: 'prometheus',
          refresh: 1,
          regex: '',
          type: 'datasource',
        },
      ).addTemplate(
        {
          hide: 0,
          datasource: '$datasource',
          label: 'Cluster',
          name: 'cluster',
          query: 'label_values(es_cluster_status, cluster)',
          refresh: 1,
          regex: '',
          type: 'query',
          sort: 1,
          includeAll: false,
        }
      ).addTemplate(
        {
          hide: 0,
          datasource: '$datasource',
          label: 'Node',
          name: 'node',
          query: 'label_values(es_jvm_uptime_seconds{cluster="$cluster"}, node)',
          refresh: 1,
          regex: '',
          type: 'query',
          sort: 1,
          includeAll: true,
        }
      )
      .addRow(replicasRow),
  },
}
