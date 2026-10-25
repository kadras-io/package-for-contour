# Corporate Proxy

Unlike other Kadras packages, this package has no `proxy` settings, because they wouldn't have any effect:

* Contour only connects to the Kubernetes API server and to Envoy, both inside the cluster.
* Envoy connects to the backends it routes traffic to, as configured in the routes. It doesn't use the `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` environment variables.

To trust a custom CA when Envoy connects to a backend over TLS, configure it on the route. See [upstream TLS](https://projectcontour.io/docs/latest/config/upstream-tls/) for HTTPProxy and [BackendTLSPolicy](https://gateway-api.sigs.k8s.io/api-types/backendtlspolicy/) for the Gateway API.
