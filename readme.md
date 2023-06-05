# Otel POC!

This file contains details to the Otel POC.

## File Descriptions

1.  `nginx.yaml` : Nginx deployment file
2.  `opentelemetry-operator.yaml` : Implementation of K8s-operator managing
a. Opentelemetry Collector
b. Auto-Instrumentation
3.  `rbac.yaml` : Role-based access control (rbac) configuration file. Defines rules around different K8s objects and actions allowed for a particular role.
4.  `collector.yaml` : Opentelemetry Collector configuration file defining the various pipelines for different signals and other important details.

## EKS
Metrics Pipeline Configuration
* Receivers: 
- [k8s_cluster](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/k8sclusterreceiver)
- [kubeletstats](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/kubeletstatsreceiver)
* Processor:
- [batch](https://github.com/open-telemetry/opentelemetry-collector/tree/main/processor/batchprocessor)
- [metricstransform](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/metricstransformprocessor)
* Exporter:
- [otlphttp](https://github.com/open-telemetry/opentelemetry-collector/tree/main/exporter/otlphttpexporter)
  

## RDS
Metrics Pipeline Configuration
* Receivers: 
- [postgresql](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/postgresqlreceiver)
* Processor:
- [batch](https://github.com/open-telemetry/opentelemetry-collector/tree/main/processor/batchprocessor)
- [metricstransform](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/metricstransformprocessor)
* Exporter:
- [otlphttp](https://github.com/open-telemetry/opentelemetry-collector/tree/main/exporter/otlphttpexporter)