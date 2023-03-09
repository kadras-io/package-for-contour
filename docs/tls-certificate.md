# TLS Certificate

The communication between Contour and Envoy is secured via mutual TLS authentication. By default, Contour generates the necessary TLS certificates via a `Job`.

For production, it's recommended to delegate the certificate issuance and renewal to Cert Manager. This package supports instructing Cert Manager to generate the necessary TLS certificates via a dedicated configuration.

```yaml
certificates:
  useCertManager: true
  duration: 8760h
  renewBefore: 360h
```
