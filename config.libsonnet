{
  _config+:: {

    esJvmHeapUseThreshold: 75,
    esDiskLowWaterMark: 85,
    esDiskHighWaterMark: 90,

    // For links between grafana dashboards, you need to tell us if your grafana
    // servers under some non-root path.
    grafanaPrefix: '',
  },
}
