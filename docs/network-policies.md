# Network Policies

## Allowing traffic from Envoy

If your applications run in namespaces with a default-deny [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/), allow the traffic from Envoy, which forwards the requests to your Services. Otherwise, the routes return `503 Service Unavailable`.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-envoy
  namespace: my-namespace
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: projectcontour
          podSelector:
            matchLabels:
              app: envoy
      ports:
        - port: 8080
```

Use the namespace of the package, if you changed it, and the port the application container listens on (the target port of the Service, not the Service port).

## Why the package doesn't include network policies

The traffic of Contour and Envoy can't be restricted in a way that works on every cluster:

* Envoy accepts traffic from any client, and forwards it to the Services referenced by your routes, in any namespace and on any port.
* Contour and the `contour-certgen` Job access the Kubernetes API server, whose address depends on the cluster. Depending on the network plugin, a policy matching it might not work, and a wrong one would leave Envoy without configuration.
* The only traffic that could be restricted, from Envoy to Contour on port 8001, already requires mutual TLS with the certificates described in [TLS](tls.md#internal-certificates).

To restrict it further on your cluster, apply your own policies to the package namespace. Envoy listens on ports 8080 and 8443, and exposes metrics and health checks on port 8002. Contour serves the configuration to Envoy on port 8001, and exposes metrics and health checks on port 8000.
