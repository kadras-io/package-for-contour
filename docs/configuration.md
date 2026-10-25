# Configuration

The package values cover the decisions most installations need to make: exposure, high availability, observability, and TLS. Everything else can still be customized in two ways.

## Contour configuration file

Contour reads its [configuration file](https://projectcontour.io/docs/latest/configuration/#configuration-file) from the `contour` ConfigMap. The package computes it from the values, then merges `contour.config` on top, so its keys take precedence.

```yaml
contour:
  config:
    disablePermitInsecure: true
    accesslog-level: error
    timeouts:
      request-timeout: 30s
```

Use it for features like [global rate limiting](https://projectcontour.io/docs/latest/guides/global-rate-limiting/), [external authorization](https://projectcontour.io/docs/latest/guides/external-authorization/), [overload management](https://projectcontour.io/docs/latest/config/overload-manager/), or the TLS version (see [tls.md](tls.md#tls-version)).

## ytt overlays

Any Kubernetes resource of the package can be customized with a [ytt overlay](https://carvel.dev/ytt/docs/latest/ytt-overlays/), stored in a Secret and referenced from the PackageInstall via the `ext.packaging.carvel.dev/ytt-paths-from-secret-name.0` annotation.

```shell
kubectl create secret generic contour-overlays -n kadras-system --from-file=overlays.yml
kubectl annotate packageinstall contour -n kadras-system \
  ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=contour-overlays
```

### Resources

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "envoy"}})
---
spec:
  template:
    spec:
      containers:
        #@overlay/match by="name"
        - name: envoy
          resources:
            requests:
              cpu: 500m
              memory: 512Mi
            limits:
              memory: 1Gi
```

### Node placement

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "envoy"}})
---
spec:
  template:
    spec:
      #@overlay/match missing_ok=True
      nodeSelector:
        node-role.kubernetes.io/ingress: ""
      #@overlay/match missing_ok=True
      tolerations:
        - key: node-role.kubernetes.io/ingress
          operator: Exists
          effect: NoSchedule
```
