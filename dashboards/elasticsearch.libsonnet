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
      // Cluster row
      // ==========================================
      local clusterStatusGraph =
        graphPanel.new(
          title='Cluster status',
          datasource='$datasource',
          fill=1,
          span=3
        ).addTarget(
          prometheus.target(
            'max(es_cluster_status{cluster="elasticsearch"}) == bool 0',
            legendFormat='Green'
          )
        ).addTarget(
          prometheus.target(
            'max(es_cluster_status{cluster="elasticsearch"}) == bool 1',
            legendFormat='Yellow'
          )
        ).addTarget(
          prometheus.target(
            'max(es_cluster_status{cluster="elasticsearch"}) == bool 2',
            legendFormat='Red'
          )
        );

      local clusterNodesGraph =
        graphPanel.new(
          title='Cluster nodes',
          datasource='$datasource',
          span=3
        ).addTarget(
          prometheus.target(
            'min(es_cluster_nodes_number{cluster="$cluster"})'
          )
        );

      local clusterDataNodesGraph =
        graphPanel.new(
          title='Cluster data nodes',
          datasource='$datasource',
          span=3
        ).addTarget(
          prometheus.target(
            'min(es_cluster_datanodes_number{cluster="$cluster"})'
          )
        );

      local clusterPendingTasksGraph =
        graphPanel.new(
          'Cluster pending tasks',
          datasource='$datasource',
          span=3
        ).addTarget(
          prometheus.target(
            'max(es_cluster_pending_tasks_number{cluster="$cluster"})'
          )
        );

      local clusterRow = row.new(
        height='100',
        title='Cluster',
      ).addPanel(clusterStatusGraph)
                         .addPanel(clusterNodesGraph)
                         .addPanel(clusterDataNodesGraph)
                         .addPanel(clusterPendingTasksGraph);


      // ==========================================
      // Shards row
      // ==========================================
      local activeShards =
        graphPanel.new(
          'Cluster active shards',
          span=6,
          datasource='$datasource',
        ).addTarget(
          prometheus.target(
            'max(es_cluster_shards_number{cluster="$cluster",type="active"})',
            legendFormat='All shards'
          )
        ).addTarget(
          prometheus.target(
            'max(es_cluster_shards_number{cluster="$cluster",type="active_primary"})',
            legendFormat='Primary shards'
          )
        );

      local nonActiveShards =
        graphPanel.new(
          'Cluster non-active shards',
          span=6,
          datasource='$datasource',
        ).addTarget(
          prometheus.target(
            'max(es_cluster_shards_number{cluster="$cluster",type="initializing"})',
            legendFormat='Initializing'
          )
        ).addTarget(
          prometheus.target(
            'max(es_cluster_shards_number{cluster="$cluster",type="relocating"})',
            legendFormat='Relocating'
          )
        ).addTarget(
          prometheus.target(
            'max(es_cluster_shards_number{cluster="$cluster",type="unassigned"})',
            legendFormat='Unassigned'
          )
        );

      local shardsRow = row.new(
        // height='200',
        title='Shards',
      ).addPanel(activeShards)
                        .addPanel(nonActiveShards);


      // ==========================================
      // Threadpools row
      // Cumulative number of processed requests per threadpool name/type
      // ==========================================
      /*
      local threadloopTypeGraph =
        graphPanel.new(
          '_OVERRIDE_ completed',
          span=2.4,
          datasource='$datasource',
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{cluster="$cluster",name="$pool_name"})'
          )
        ) + {
          title: '$pool_name tasks',
          repeat: 'pool_name',
          repeatDirection: 'h',
        };
      */

      local threadpoolTypeGraph =
        graphPanel.new(
          'ThreadPool tasks',
          span=1,
          datasource='$datasource',
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="index"})',
            legendFormat='Index'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="search"})',
            legendFormat='Search'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="search_throttled"})',
            legendFormat='Search Throttled'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="refresh"})',
            legendFormat='Refresh'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="write"})',
            legendFormat='Write'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="get"})',
            legendFormat='Get'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="warmer"})',
            legendFormat='Warmer'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="snapshot"})',
            legendFormat='Snapshot'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="management"})',
            legendFormat='Management'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="generic"})',
            legendFormat='Generic'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="listener"})',
            legendFormat='Listener'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="analyze"})',
            legendFormat='Analyze'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="force_merge"})',
            legendFormat='Force Merge'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="flush"})',
            legendFormat='Flush'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="fetch_shard_store"})',
            legendFormat='Fetch Shard Store'
          )
        ).addTarget(
          prometheus.target(
            'max(es_threadpool_tasks_number{type="queue", cluster="$cluster", node=~"$node", name="fetch_shard_started"})',
            legendFormat='Fetch Shard Started'
          )
        );

      local threadpools = row.new(
        height='200',
        title='Threadpools',
      ).addPanel(threadpoolTypeGraph);


      // ==========================================
      // System row
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

      // ==========================================
      // Documents and Latencies row
      // ==========================================
      local documentsIndexingRateGraph =
        graphPanel.new(
          'Documents indexing rate',
          span=3,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_indexing_index_count{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local indexingLatencyGraph =
        graphPanel.new(
          'Indexing latency',
          span=3,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_indexing_index_time_seconds{cluster="$cluster", node=~"$node"}[$interval:$resolution]) / rate(es_indices_indexing_index_count{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local searchRateGraph =
        graphPanel.new(
          'Search rate',
          span=3,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_search_query_count{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local searchLatencyGraph =
        graphPanel.new(
          'Search latency',
          span=3,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_search_query_time_seconds{cluster="$cluster", node=~"$node"}[$interval:$resolution]) / rate(es_indices_search_query_count{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local documentsCountIncReplicasGraph =
        graphPanel.new(
          'Documents count (with replicas)',
          span=4,
          // min=0,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('es_indices_doc_number{cluster="$cluster", node=~"$node"}', legendFormat='{{node}}')
        ) + {
          fill: 3,
          tooltip: {
            shared: true,
            sort: 2,
            value_type: 'individual',
          },
        };

      local documentsDeletingRateGraph =
        graphPanel.new(
          'Documents deleting rate',
          span=4,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_doc_deleted_number{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local documentsMergingRateGraph =
        graphPanel.new(
          'Documents merging rate',
          span=4,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_merges_total_docs_count{cluster="$cluster",node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local docsAndLatenciesRow = row.new(
        height='400',
        title='Documents and Latencies',
      ).addPanel(documentsIndexingRateGraph)
                                  .addPanel(indexingLatencyGraph)
                                  .addPanel(searchRateGraph)
                                  .addPanel(searchLatencyGraph)
                                  .addPanel(documentsCountIncReplicasGraph)
                                  .addPanel(documentsDeletingRateGraph)
                                  .addPanel(documentsMergingRateGraph);

      // ==========================================
      // Caches row
      // ==========================================
      local cacheFieldDataMemSizeGraph =
        graphPanel.new(
          'Field data memory size',
          span=6,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('es_indices_fielddata_memory_size_bytes{cluster="$cluster", node=~"$node"}', legendFormat='{{node}}')
        );

      local cacheFieldDataEvictionsGraph =
        graphPanel.new(
          'Field data evictions',
          span=6,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_fielddata_evictions_count{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local cacheQuerySizeGraph =
        graphPanel.new(
          'Query cache size',
          span=3,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('es_indices_querycache_cache_size_bytes{cluster="$cluster", node=~"$node"}', legendFormat='{{node}}')
        );

      local cacheQueryEvictionsGraph =
        graphPanel.new(
          'Query cache evictions',
          span=3,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_querycache_evictions_count{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local cacheQueryHitsGraph =
        graphPanel.new(
          'Query cache hits',
          span=3,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_querycache_hit_count{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local cacheQueryMissesGraph =
        graphPanel.new(
          'Query cache misses',
          span=3,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_querycache_miss_number{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local cachesRow = row.new(
        height='400',
        title='Caches',
      ).addPanel(cacheFieldDataMemSizeGraph)
                        .addPanel(cacheFieldDataEvictionsGraph)
                        .addPanel(cacheQuerySizeGraph)
                        .addPanel(cacheQueryEvictionsGraph)
                        .addPanel(cacheQueryHitsGraph)
                        .addPanel(cacheQueryMissesGraph);

      // ==========================================
      // Throttling row
      // ==========================================
      local throttlingIndexingGraph =
        graphPanel.new(
          'Indexing throttling',
          span=6,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_indexing_throttle_time_seconds{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local throttlingMergingGraph =
        graphPanel.new(
          'Merging throttling',
          span=6,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_indices_merges_total_throttled_time_seconds{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}}')
        );

      local throttlingRow = row.new(
        height='400',
        title='Throttling',
      ).addPanel(throttlingIndexingGraph)
                            .addPanel(throttlingMergingGraph);

      // ==========================================
      // JVM row
      // ==========================================
      local jvmHeapUsedGraph =
        graphPanel.new(
          'Heap used',
          span=4,
          datasource='$datasource',
          format='bytes',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('es_jvm_mem_heap_used_bytes{cluster="$cluster", node=~"$node"}', legendFormat='{{node}} - heap used')
        );

      local jvmGCcountGraph =
        graphPanel.new(
          'GC count',
          span=4,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_jvm_gc_collection_count{cluster="$cluster",node=~"$node"}[$interval:$resolution])', legendFormat='{{node}} - {{gc}}')
        );

      local jvmGCTimeGraph =
        graphPanel.new(
          'GC time',
          span=4,
          datasource='$datasource',
          legend_alignAsTable=true,
          legend_avg=true,
          legend_current=true,
          legend_max=true,
          legend_min=true,
          legend_hideEmpty=false,
          legend_hideZero=false,
          legend_values=true,
        ).addTarget(
          prometheus.target('rate(es_jvm_gc_collection_time_seconds{cluster="$cluster", node=~"$node"}[$interval:$resolution])', legendFormat='{{node}} - {{gc}}')
        );

      local jvmRow = row.new(
        height='400',
        title='JVM',
      ).addPanel(jvmHeapUsedGraph)
                     .addPanel(jvmGCcountGraph)
                     .addPanel(jvmGCTimeGraph);

      // ==========================================
      dashboard.new('OpenShift Logging / Elasticsearch Nodes', time_from='now-3h')
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
        // k8s/ns/openshift-config-managed/configmaps/grafana-dashboard-cluster-total
        {
          allValue: null,
          auto: false,
          auto_count: 30,
          auto_min: '10s',
          current: {
            text: '5m',
            value: '5m',
          },
          datasource: '$datasource',
          hide: 2,
          includeAll: false,
          label: null,
          multi: false,
          name: 'interval',
          options: [
            {
              selected: true,
              text: '4h',
              value: '4h',
            },
          ],
          query: '4h',
          refresh: 2,
          regex: '',
          skipUrlSync: false,
          sort: 1,
          tagValuesQuery: '',
          tags: [

          ],
          tagsQuery: '',
          type: 'interval',
          useTags: false,
        }

        /*
        {
          allValue: null,
          current: {
            tags: [],
            text: '1m',
            value: '1m',
          },
          datasource: 'prometheus',
          hide: 0,
          includeAll: false,
          label: 'Interval',
          multi: false,
          name: 'interval',
          options: [
            {
              selected: false,
              text: '15s',
              value: '15s',
            },
            {
              selected: false,
              text: '30s',
              value: '30s',
            },
            {
              selected: true,
              text: '1m',
              value: '1m',
            },
            {
              selected: false,
              text: '5m',
              value: '5m',
            },
            {
              selected: false,
              text: '1h',
              value: '1h',
            },
            {
              selected: false,
              text: '6h',
              value: '6h',
            },
            {
              selected: false,
              text: '1d',
              value: '1d',
            },
          ],
          query: '15s, 30s, 1m, 5m, 1h, 6h, 1d',
          refresh: 0,
          type: 'custom',
        }
        */
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
      ).addTemplate(
        {
          hide: 2,
          datasource: '$datasource',
          label: 'Shard',
          name: 'shard_type',
          query: 'label_values(es_cluster_shards_number, type)',
          refresh: 1,
          regex: '',
          type: 'query',
          sort: 1,
          includeAll: true,
        }
      ).addTemplate(
        template.new(
          name='resolution',
          datasource='$datasource',
          query='30s,5m,1h',
          current='5m',
          hide='',
          refresh=2,
          includeAll=false,
          sort=1
        ) + {
          auto: false,
          auto_count: 30,
          auto_min: '10s',
          skipUrlSync: false,
          type: 'interval',
          options: [
            {
              selected: false,
              text: '30s',
              value: '30s',
            },
            {
              selected: true,
              text: '5m',
              value: '5m',
            },
            {
              selected: false,
              text: '1h',
              value: '1h',
            },
          ],
        }
      ).addTemplate(
        {
          hide: 2,
          datasource: '$datasource',
          label: 'Threadpool Type name',
          name: 'pool_name',
          query: 'label_values(es_threadpool_tasks_number, name)',
          refresh: 1,
          regex: '',
          type: 'query',
          sort: 1,
          includeAll: true,
        }
      )
      .addRow(clusterRow)
      .addRow(shardsRow)
      .addRow(threadpools)
      .addRow(systemRow)
      .addRow(docsAndLatenciesRow)
      .addRow(cachesRow)
      .addRow(throttlingRow)
      .addRow(jvmRow) + {
        graphTooltip: 1,
      },
  },
}
