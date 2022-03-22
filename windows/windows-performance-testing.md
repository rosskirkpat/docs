# Perf Collection

## Options

Good summary: https://argonsys.com/microsoft-cloud/library/performance-data-collection-on-nano-server/

### wpr.exe

https://docs.microsoft.com/en-us/windows-hardware/test/wpt/introduction-to-wpr
https://docs.microsoft.com/en-us/windows-hardware/test/wpt/windows-performance-recorder

Pros:
 - deep debugging 

Cons: 
 - not customer friendly
 - LOTS of data and historical will be dropped
 - Needs special tools to review data
 - difficult to correlate

### typeperf.exe

https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-xp/bb490960(v=technet.10)?redirectedfrom=MSDN

Pros:
 - detailed metrics
 - potentially could use any type of metric, even custom

Cons: 
 - not customer friendly
 - difficult to correlate

### windows_exporter - Perferred

https://github.com/prometheus-community/windows_exporter
https://www.robustperception.io/taking-snapshots-of-prometheus-data

Pros:
 - well excepted format
 - used by upstream perf tools (https://github.com/kubernetes/perf-tests/tree/master/clusterloader2)
 - user friendly
 - correlation to what is happening in cluster - https://www.robustperception.io/taking-snapshots-of-prometheus-data
 - https://github.com/kubernetes/community/blob/master/contributors/devel/sig-testing/e2e-tests.md#performance-evaluation

Cons:
 - no custom metrics
 - requires promethus installed to grab data

### telegraph

https://github.com/influxdata/telegraf

Pros:
 - Configurable to different kinds of syncs
 - config file based 

Cons:
 - not as widely adopted

### k8s metrics api

Pros:
 - no external components
 - we've seen issues collection metrics at high volume

Cons:
 - doesn't have as many details
 - needs additional components to collect and analyze

## Additional Info


## memory allocation options:

https://docs.microsoft.com/en-us/windows/win32/memory/comparing-memory-allocation-methods?redirectedfrom=MSDN

## Perf and Memory tools

https://docs.microsoft.com/en-us/sysinternals/downloads/vmmap
https://docs.microsoft.com/en-us/sysinternals/downloads/process-explorer

## page file info

https://techcommunity.microsoft.com/t5/windows-blog-archive/pushing-the-limits-of-windows-virtual-memory/ba-p/723750
https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/create-a-pagefile
https://p0w3rsh3ll.wordpress.com/2013/03/17/pagefile-configuration-and-guidance/
https://docs.microsoft.com/en-US/windows/client-management/determine-appropriate-page-file-size

## Test configuration

Releases (1.17 - 1.20)
 - https://github.com/kubernetes/test-infra/blob/05cd2bdfae4b97bca8867bca31c899a2cde4f090/config/jobs/kubernetes-sigs/sig-windows/release-1.20-windows.yaml#L168
 - `--ginkgo-parallel=4`

Release 1.19 containerd
 - https://github.com/kubernetes/test-infra/blob/05cd2bdfae4b97bca8867bca31c899a2cde4f090/config/jobs/kubernetes-sigs/sig-windows/release-1.19-windows.yaml#L276
 - `--ginkgo-parallel=8`
 - 42m31s. 

Release 1.20 (containerd)
-  https://github.com/kubernetes/test-infra/blob/05cd2bdfae4b97bca8867bca31c899a2cde4f090/config/jobs/kubernetes-sigs/sig-windows/release-1.20-windows.yaml#L168
-  - --ginkgo-parallel=4  
- 53m52s

Head Containerd
 - https://github.com/kubernetes/test-infra/blob/05cd2bdfae4b97bca8867bca31c899a2cde4f090/config/jobs/kubernetes-sigs/sig-windows/sig-windows-config.yaml#L473
 - `--ginkgo-parallel=8`
 - 1h5m58s

Head Docker
 - https://github.com/kubernetes/test-infra/blob/05cd2bdfae4b97bca8867bca31c899a2cde4f090/config/jobs/kubernetes-sigs/sig-windows/sig-windows-config.yaml#L365
 - `--ginkgo-parallel=8`

## Perf Analysis with clusterloader2
https://kubernetes.slack.com/archives/C09QZTRH7/p1606723765070400
https://youtu.be/gNj19Icb32g?t=898


## kube-prometheus 

## wmi_expoter
https://github.com/prometheus-community/windows_exporter

## windows links
https://github.com/kubernetes-monitoring/kubernetes-mixin/blob/master/dashboards/windows.libsonnet
https://github.com/prometheus-operator/kube-prometheus/blob/master/docs/developing-prometheus-rules-and-grafana-dashboards.md

### configuration
https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/additional-scrape-config.md
https://prometheus.io/docs/prometheus/latest/configuration/configuration/#static_config


## Metrics collection

https://grafana.com/blog/2019/04/01/how-were-using-prometheus-subqueries-at-grafana-labs./
https://acloudguru.com/hands-on-labs/using-the-prometheus-http-api


ARTIFACTS="$HOME/artifacts"

```
kubectl exec -it prometheus-k8s-0 -c prometheus -- wget localhost\:9090/api/v1/query?query=quantile_over_time\(0.99%2C%20node%3Awindows_node_cpu_utilisation%3Aavg1m%5B1h%5D\) -O 95.txt
kubectl cp prometheus-k8s-0:/prometheus/95.txt ./95.txt
cpu=$(cat 95.txt | jq -r '.data.result[0].value[1]') 
sed -i "s/NINETYNINE/$cpu/g" template.txt 
```


```
{
  "version": "v1",
  "dataItems": [
    {
      "data": {
        "Perc50": FIFTY,
        "Perc90": NINETY,
        "Perc99": NINETYNINE
      },
      "unit": "%",
      "labels": {
        "Resource": "node",
      }
    },
}
```


gsutil cp -r dir gs://my-bucket
gsutil cp -r my-kube-prometheus gs://k8s-perf-testing 

gsutil cp -r _output gs://k8s-perf-testing/logs/ci-kubernetes-e2e-aks-engine-azure-master-windows-containerd/$RANDOM/


export ARTIFACTS="$HOME/artifacts/$RANDOM/artifacts" && ./win-ci-logs-collector.sh test-containerd-6684.westus2.cloudapp.azure.com ~/out/test-containerd-6684/

TODO:
    - wire in another testgrid output for example
    - another metric?
    - prom loading locally.
    
Demo:
    - show kube-prom
    - show grafana
    - show prom
    - show script 
    - show perfdash
    - show mounting loca prom
