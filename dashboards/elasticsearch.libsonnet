local promgrafonnet = import '../lib/promgrafonnet/promgrafonnet.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
// local yaxes = grafana.yaxes; // I need to create custom promgrafonnet wrapper file?
local singlestat = grafana.singlestat;
local gauge = promgrafonnet.gauge;

{
  grafanaDashboards+:: {
    'logging-elasticsearch.json':

      // ==========================================
      local clusterStatusGraph =
        singlestat.new(
          'Cluster status',
          datasource='$datasource',
          span=2
        ).addTarget(
          prometheus.target(
            'max(es_cluster_status{cluster="$cluster"})'
          )
        ) + {
          colorBackground: true,
          colors: [
            'rgba(50, 172, 45, 0.97)',
            'rgba(255, 166, 0, 0.89)',
            'rgba(245, 54, 54, 0.9)',
          ],
          thresholds: '1,2',
          valueMaps: [
            {
              op: '=',
              text: 'GREEN',
              value: '0',
            },
            {
              op: '=',
              text: 'YELLOW',
              value: '1',
            },
            {
              op: '=',
              text: 'RED',
              value: '2',
            },
          ],
        };

      // Histogram seem to require a lot of graphPanel customization.
      // We shall consider creating a new component for it.
      local clusterHealthHistoryGraph =
        graphPanel.new(
          null,
          span=4,
          datasource='$datasource',
        ).addTarget(
          prometheus.target(
            '(es_cluster_status{cluster="$cluster"} == 0) + 1',
            legendFormat='GREEN',
            intervalFactor=10,
          )
        ).addTarget(
          prometheus.target(
            '(es_cluster_status{cluster="$cluster"} == 1)',
            legendFormat='YELLOW',
            intervalFactor=10,
          )
        ).addTarget(
          prometheus.target(
            '(es_cluster_status{cluster="$cluster"} == 2) - 1',
            legendFormat='RED',
            intervalFactor=10,
          )
        ) + {
          stack: true,
          bars: true,
          fill: 10,
          lines: false,
          percentage: true,
          legend: {
            alignAsTable: false,
            avg: false,
            current: false,
            max: false,
            min: false,
            rightSide: false,
            show: false,
            total: false,
            values: false,
          },
          seriesOverrides: [
            {
              alias: 'GREEN',
              color: 'rgba(50, 172, 45, 0.97)',
            },
            {
              alias: 'YELLOW',
              color: 'rgba(255, 166, 0, 0.89)',
            },
            {
              alias: 'RED',
              color: 'rgba(245, 54, 54, 0.9)',
            },
          ],
          yaxes: [
            {
              format: 'none',
              label: null,
              logBase: 1,
              max: '100',
              min: '0',
              show: false,
            },
            {
              format: 'short',
              label: null,
              logBase: 1,
              max: null,
              min: null,
              show: false,
            },
          ],
        };

      local clusterRow = row.new(
        height='100',
        title='Cluster',
      ).addPanel(clusterStatusGraph)
                         .addPanel(clusterHealthHistoryGraph)
                         .addPanel(clusterStatusGraph)
                         .addPanel(clusterStatusGraph)
                         .addPanel(clusterStatusGraph);

      // ==========================================
      local shardsActiveGraph =
        graphPanel.new(
          'Active shards',
          span=2.39,
          datasource='$datasource',
        );

      local shardsRow = row.new(
        height='100',
        title='Shards',
      ).addPanel(shardsActiveGraph)
                        .addPanel(shardsActiveGraph)
                        .addPanel(shardsActiveGraph)
                        .addPanel(shardsActiveGraph)
                        .addPanel(shardsActiveGraph);

      // ==========================================
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
        ).addTarget(
          prometheus.target('es_os_cpu_percent{cluster="$cluster", node=~"$node"}', legendFormat='{{node}}')
        );

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
      .addRow(clusterRow)
      .addRow(shardsRow)
      .addRow(systemRow),
  },
}
