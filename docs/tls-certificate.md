# Configuring TLS between Envoy and Contour

The communication between Contour and Envoy is secured via mutual TLS authentication. By default, Contour generates the necessary TLS certificates via a `Job`.

For production, it's recommended to delegate the certificate issuance and renewal to Cert Manager. You can install [cert-manager](https://github.com/kadras-io/package-for-cert-manager) from the Kadras project. This package supports instructing Cert Manager to generate the necessary TLS certificates via a dedicated configuration.

```yaml
certificates:
  useCertManager: true
  duration: 8760h
  renewBefore: 360h
```

For more information, check the Contour documentation for [enabling TLS between Envoy and Contour](https://projectcontour.io/docs/latest/grpc-tls-howto).
