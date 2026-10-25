# Observability

## Logs

The log level and format apply to both Contour and Envoy.

```yaml
observability:
  logging:
    level: info
    format: json
```

* `level` is one of `debug`, `info`, `warn`, `error`. Envoy uses it as is, while Contour only distinguishes between `debug` and the rest.
* `format` is one of `text` and `json`. It applies to the Contour logs and to the Envoy [access logs](https://projectcontour.io/docs/latest/config/access-logging/). To customize the access log fields, use `contour.config` (see [configuration.md](configuration.md)).

## Metrics

Contour and Envoy expose metrics in the Prometheus format, on port 8000 (`/metrics`) and 8002 (`/stats/prometheus`) respectively. By default, their Pods are annotated for Prometheus scraping (`prometheus.io/scrape`, `prometheus.io/port`, `prometheus.io/path`). To remove the annotations:

```yaml
observability:
  metrics:
    enabled: false
```

See [collecting metrics with Prometheus](https://projectcontour.io/docs/latest/guides/prometheus/).

## Traces

Envoy can export traces to an OpenTelemetry collector via OTLP/gRPC, for example one deployed with the [OpenTelemetry Operator package](https://github.com/kadras-io/package-for-opentelemetry-operator).

```yaml
observability:
  tracing:
    enabled: true
    endpoint: http://otel-collector.observability.svc:4317
    sampling_rate: 0.1
```

* `endpoint` must point to an in-cluster Service, in the form `[http://]<service>.<namespace>[.svc[.cluster.local]]:<port>`. Contour reaches the collector through an `ExtensionService` named `contour-tracing`, which the package creates in the namespace of the collector. That namespace must exist before installing the package.
* `sampling_rate` is the fraction of requests to trace, from 0 to 1.

See [tracing support](https://projectcontour.io/docs/latest/config/tracing/).
