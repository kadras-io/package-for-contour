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

The Contour and Envoy components produce Prometheus metrics by default. You can enable them by adding PodMonitor resources as described in the Contour documentation for [collecting metrics with Prometheus](https://projectcontour.io/docs/latest/guides/prometheus).

## Traces

For more information, check the Contour documentation for [supporting distributed tracing with OpenTelemetry](https://projectcontour.io/docs/latest/config/tracing/).
