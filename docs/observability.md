# Configuring Observability

Monitor and observe the operation of Contour using logs and metrics.

## Logs

Log configuration for the Contour component can be customized as follows.

```yaml
contour:
  config:
    logFormat: text
    logLevel: info
```

You can also customize logging for the Envoy component.

```yaml
envoy:
  config:
    logLevel: info
```

Structured JSON logging can be configured for the Envoy access logs. Check the documentation for [access logs](https://projectcontour.io/docs/latest/config/access-logging/) and [structured logging](https://projectcontour.io/docs/latest/guides/structured-logs/) for more information.

## Metrics

The Contour and Envoy components produce Prometheus metrics by default. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from all its components. Check the documentation for [collecting metrics with Prometheus](https://projectcontour.io/docs/latest/guides/prometheus/).

## Traces

OpenTelemetry instrumentation is provided for distributed tracing. By default, the instrumentation is disabled. Via the `tracing.*` properties, you can enable the generation of traces and configure how they are exported to an OpenTelemetry backend.

```yaml
tracing:
  enabled: true
  collector:
    service_name: otel-collector
    service_namespace: observability
    port: 4317
```

For more information, check the Contour documentation for [supporting distributed tracing with OpenTelemetry](https://projectcontour.io/docs/latest/config/tracing/).
