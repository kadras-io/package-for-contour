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

## Metrics

The Contour and Envoy components produce Prometheus metrics by default. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically.

For more information, check the Contour documentation for [collecting metrics with Prometheus](https://projectcontour.io/docs/latest/guides/prometheus).
