{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'logging_elasticsearch.alerts',
        rules: [

          // ==========================================
          // Cluster health alerts
          // ==========================================
          {
            alert: 'Cluster_Health_Status_RED',
            expr: |||
              sum by (cluster) (es_cluster_status == 2)
            |||,
            'for': '%(esClusterHealthStatusRED)s' % $._config,
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Cluster health status is RED',
              description: 'Cluster {{ $labels.cluster }} health status has been RED for at least 2 minutes',
            },
          },
          {
            alert: 'Cluster_Health_Status_YELLOW',
            expr: |||
              sum by (cluster) (es_cluster_status == 1)
            |||,
            'for': '%(esClusterHealthStatusYELLOW)s' % $._config,
            labels: {
              severity: 'high',
            },
            annotations: {
              summary: 'Cluster health status is YELLOW',
              description: 'Cluster {{ $labels.cluster }} health status has been YELLOW for at least 20 minutes',
            },
          },

          // ==========================================
          // Bulk Requests Rejection
          // ==========================================

          {
            alert: 'Bulk_Requests_Rejection_HIGH',
            expr: |||
              round( bulk:reject_ratio:rate2m * 100, 0.001 ) > %(esBulkPctIncrease)s
            ||| % $._config,
            'for': '10m',
            labels: {
              severity: 'high',
            },
            annotations: {
              summary: 'High Bulk Rejection Ratio - {{ $value }}%',
              description: 'High Bulk Rejection Ratio at {{ $labels.node }} node in {{ $labels.cluster }} cluster',
            },
          },

          // ==========================================
          // Disk Usage
          // ==========================================

          {
            alert: 'Disk_Low_Watermark_Reached',
            expr: |||
              sum by (cluster, instance, node) (
                round(
                  (1 - (
                    es_fs_path_available_bytes /
                    es_fs_path_total_bytes
                  )
                ) * 100, 0.001)
              ) > %(esDiskLowWaterMark)s
            ||| % $._config,
            'for': '5m',
            labels: {
              severity: 'alert',
            },
            annotations: {
              summary: 'Low Watermark Reached - disk saturation is {{ $value }}%',
              description: 'Low Watermark Reached at {{ $labels.node }} node in {{ $labels.cluster }} cluster',
            },
          },
          {
            alert: 'Disk_High_Watermark_Reached',
            expr: |||
              sum by (cluster, instance, node) (
                round(
                  (1 - (
                    es_fs_path_available_bytes /
                    es_fs_path_total_bytes
                  )
                ) * 100, 0.001)
              ) > %(esDiskHighWaterMark)s
            ||| % $._config,
            'for': '5m',
            labels: {
              severity: 'alert',
            },
            annotations: {
              summary: 'High Watermark Reached - disk saturation is {{ $value }}%',
              description: 'High Watermark Reached at {{ $labels.node }} node in {{ $labels.cluster }} cluster',
            },
          },

          // Remaining space on the node:
          //   sum by (cluster, instance, node) (es_fs_path_free_bytes)
          // Though this ^^ might not be the best metric, because node can have multiple paths where the
          // data can be stored but pure sum by paths is not what ES can fully utilize.
          // Also there are known issues, see https://github.com/elastic/elasticsearch/issues/27174
          //
          // Total index size by node:
          //   sum by (cluster, instance, node) (es_index_store_size_bytes{context="total"}) // <- this does not seem to work correctly!?
          //   sum by (cluster, instance, node) (es_indices_store_size_bytes)
          {
            alert: 'Disk_Low_For_Segment_Merges',
            expr: |||
              sum by (cluster, instance, node) (es_fs_path_free_bytes) /
              sum by (cluster, instance, node) (es_indices_store_size_bytes)
              < %(esDiskSpaceRatioForMerges)s
            ||| % $._config,
            'for': '15m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Free disk may be low for optimal segment merges',
              description: 'Free disk at {{ $labels.node }} node in {{ $labels.cluster }} cluster may be low for optimal segment merges',
            },
          },

          // ==========================================
          // JVM Heap Usage
          // ==========================================
          {
            alert: 'JVM_Heap_Use_High',
            expr: |||
              sum by (cluster, instance, node) (es_jvm_mem_heap_used_percent) > %(esJvmHeapUseThreshold)s
            ||| % $._config,
            'for': '10m',
            labels: {
              severity: 'alert',
            },
            annotations: {
              summary: 'JVM Heap usage on the node is high',
              description: 'JVM Heap usage on the node {{ $labels.node }} in {{ $labels.cluster }} cluster is {{ $value }}%. There might be long running GCs now.',
            },
          },

          // ==========================================
          // CPU Usage
          // ==========================================
          {
            alert: 'System_CPU_High',
            expr: |||
              sum by (cluster, instance, node) (es_os_cpu_percent) > %(esSystemCPUHigh)s
            ||| % $._config,
            'for': '1m',
            labels: {
              severity: 'alert',
            },
            annotations: {
              summary: 'System CPU usage is high',
              description: 'System CPU usage on the node {{ $labels.node }} in {{ $labels.cluster }} cluster is {{ $value }}%',
            },
          },
          {
            alert: 'ES_Process_CPU_High',
            expr: |||
              sum by (cluster, instance, node) (es_process_cpu_percent) > %(esProcessCPUHigh)s
            ||| % $._config,
            'for': '1m',
            labels: {
              severity: 'alert',
            },
            annotations: {
              summary: 'ES process CPU usage is high',
              description: 'ES process CPU usage on the node {{ $labels.node }} in {{ $labels.cluster }} cluster is {{ $value }}%',
            },
          },

        ],
      },
    ],
  },
}
