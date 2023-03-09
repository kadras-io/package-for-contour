# Contour Configuration

Besides the available properties, Contour can be configured via an optional YAML file value passed via the `contour.configFileContents` property.

For example, you can configure the minimum TLS version and the format for the Envoy access logs.

  ```yaml
  contour:
    configFileContents:
      accesslog-format: json
      tls:
        minimum-protocol-version: 1.3
  ```

For more information, check the Contour documentation for using the [configuration file](https://projectcontour.io/docs/latest/configuration/#configuration-file).
