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

      local systemCpuUsageGraph =
        graphPanel.new(
          'CPU usage',
          span=4,
          datasource='$datasource',
          format='percent',
          min=0,
          max=100,
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
          legend_sort=true,  // not working?
        ).addTarget(
          prometheus.target('es_os_cpu_percent{cluster="$cluster", node=~"$node"}', legendFormat='{{node}}')
        );
      // + {
      //   yaxes: [
      //     {
      //       format: 'percent',
      //       label: 'CPU Usage', // this one can not be set via function parameter in graphPanel.new
      //       logBase: 1,
      //       max: 100,
      //       min: 0,
      //       show: true,
      //     },
      //     {
      //       format: 'short',
      //       label: null,
      //       logBase: 1,
      //       max: null,
      //       min: null,
      //       show: false,
      //     },
      //   ],
      // };

      local systemMemoryUsageGraph =
        graphPanel.new(
          'Memory usage',
          span=4,
          datasource='$datasource',
          format='bytes',
          min=0,
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
          legend_sort=true,  // not working?
        ).addTarget(
          prometheus.target('es_os_mem_used_bytes{cluster="$cluster", node=~"$node"}', legendFormat='{{node}}')
        );

      local systemDiskUsageGraph =
        graphPanel.new(
          'Disk usage',
          span=4,
          datasource='$datasource',
          format='percentunit',
          min=0,
          max=1,
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
          legend_sort=true,  // not working?
        ).addTarget(
          prometheus.target('1 - es_fs_path_available_bytes{cluster="$cluster",node=~"$node"} / es_fs_path_total_bytes{cluster="$cluster",node=~"$node"}', legendFormat='{{node}} - {{path}}')
        ) + {
          thresholds: [
            {
              colorMode: 'custom',
              fill: true,
              fillColor: 'rgba(216, 200, 27, 0.27)',
              op: 'gt',
              value: 0.8,
            },
            {
              colorMode: 'custom',
              fill: true,
              fillColor: 'rgba(234, 112, 112, 0.22)',
              op: 'gt',
              value: 0.9,
            },
          ],
        };

      local systemRow = row.new(
        height='400',
        title='System',
      ).addPanel(systemCpuUsageGraph)
                        .addPanel(systemMemoryUsageGraph)
                        .addPanel(systemDiskUsageGraph);

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
      .addRow(systemRow),
  },
}
