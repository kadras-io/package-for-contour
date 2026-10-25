# Gateway API

Contour serves three APIs to route traffic into the cluster, all through the same Envoy instances:

* the Kubernetes [Gateway API](https://gateway-api.sigs.k8s.io) (`HTTPRoute`, `GRPCRoute`, `TLSRoute`, `TCPRoute`);
* the Kubernetes `Ingress` API, via the `contour` IngressClass, which the package marks as the cluster default;
* the Contour `HTTPProxy` API.

## The default Gateway

The package creates a `contour` GatewayClass and a Gateway named `contour` in the package namespace, and configures Contour to serve it ([static provisioning](https://projectcontour.io/docs/latest/config/gateway-api/#static-provisioning)). The Gateway has these listeners:

| Listener | Port | Protocol | Serves |
|----------|------|----------|--------|
| `http` | 80 | `HTTP` | `HTTPRoute`, `HTTPProxy`, and `Ingress` over HTTP. |
| `contour-https` | 443 | `projectcontour.io/https` | `HTTPProxy` and `Ingress` over HTTPS, with the TLS settings defined on each resource. |
| `https` | 443 | `HTTPS` | `HTTPRoute` for `*.<domain>` over HTTPS. Only when `domain` and `tls.issuer` are set. |
| `http-redirect` | 80 | `HTTP` | Redirects HTTP requests for `*.<domain>` to HTTPS. Only when `domain` and `tls.issuer` are set, and `tls.http_redirect` is enabled. |

Attach a route to the Gateway by referencing it and, optionally, the listener:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app
spec:
  parentRefs:
    - name: contour
      namespace: projectcontour
      sectionName: https
  hostnames:
    - my-app.example.com
  rules:
    - backendRefs:
        - name: my-app
          port: 80
```

Contour reports the state of the Gateway, its listeners, and the attached routes in their `status`. The `status` of the GatewayClass stays `Pending` ("Waiting for controller"): in static provisioning, Contour doesn't manage GatewayClasses. The Gateway is only `Programmed` once the Envoy Service has an address, which requires a `LoadBalancer` Service.

By default, routes from any namespace can attach to the Gateway. Use `allowed_routes: Same` to only allow routes in the package namespace.

## HTTPS for a domain

When `domain` and `tls.issuer` are set, the package requests a wildcard certificate for `*.<domain>` from the given cert-manager ClusterIssuer and adds the `https` listener to the Gateway. cert-manager must be installed in the cluster. With an ACME issuer like Let's Encrypt, wildcard certificates require a DNS-01 challenge.

```yaml
gateway:
  domain: example.com
  tls:
    issuer: letsencrypt
    http_redirect: true
```

With `http_redirect` (enabled by default), HTTP requests for `*.<domain>` are redirected to HTTPS by the `http-redirect` listener, which takes precedence over the `http` one for those hosts. Attach the routes for the domain to the `https` listener via `sectionName: https`. To serve some of them over plain HTTP, disable `http_redirect`.

## Gateway API CRDs

Gateway API is not part of Kubernetes: its resources are CRDs, released separately. Contour requires the CRDs from the experimental channel, in the version it supports (Gateway API v1.3.0 for Contour 1.33). The package installs them by default.

The standard channel is not enough: Contour 1.33 watches `TLSRoute` and `TCPRoute` in version `v1alpha2` and `BackendTLSPolicy` in version `v1alpha3`, which are only served by the experimental channel. If they're missing, Contour fails to start. That's also why the CRDs are not the latest Gateway API release: they follow the version tested with Contour, listed in its [compatibility matrix](https://github.com/projectcontour/contour/blob/main/versions.yaml), and are updated together with Contour.

If the Gateway API CRDs are already managed by something else in the cluster, disable their installation. They must still be from the experimental channel and serve the versions above.

```yaml
gateway:
  install_crds: false
```

## Disabling the Gateway

Without the default Gateway, Contour serves `HTTPProxy` and `Ingress` resources only.

```yaml
gateway:
  enabled: false
```

## Why only one Gateway

Contour can also run as a [Gateway provisioner](https://projectcontour.io/docs/latest/config/gateway-api/#dynamic-provisioning), deploying a dedicated Contour and Envoy, with its own load balancer, for every Gateway. This package doesn't support that mode: one shared Gateway covers the needs of a platform, and every component stays configurable through the package values and ytt overlays.
