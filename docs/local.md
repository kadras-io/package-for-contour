# Running Locally

The package defaults target production clusters, where Envoy is exposed through a `LoadBalancer` Service. On a local cluster, use one of the presets below, which are also used by the package tests.

## kind

kind has no load balancer implementation. Instead, Envoy runs on every worker node and listens on the host ports 80 and 443, which kind maps to your machine.

Create a cluster mapping the ports 80 and 443 of a node to your machine:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
      - containerPort: 443
        hostPort: 443
```

Then install the package with the [kind preset](examples/local-kind-values.yml). Since host ports are only allowed by the `privileged` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), the package enforces it on its namespace instead of `restricted`.

```yaml
contour:
  replicas: 1
envoy:
  kind: DaemonSet
  host_ports:
    enabled: true
  service:
    type: ClusterIP
```

## k3d

k3d runs a load balancer for the `LoadBalancer` Services, so the default Envoy Service works. Disable the bundled Traefik ingress controller and map the ports 80 and 443 of the load balancer to your machine:

```shell
k3d cluster create kadras \
  --k3s-arg "--disable=traefik@server:*" \
  -p "80:80@loadbalancer" -p "443:443@loadbalancer"
```

Then install the package with the [k3d preset](examples/local-k3d-values.yml), which only lowers the number of replicas:

```yaml
contour:
  replicas: 1
envoy:
  replicas: 1
```

## Domains

To route traffic by host name without configuring DNS, use a wildcard DNS service like [sslip.io](https://sslip.io), which resolves `<anything>.127.0.0.1.sslip.io` to `127.0.0.1`. For example, to serve HTTPRoutes over HTTPS with the private CA from the [cert-manager package](https://github.com/kadras-io/package-for-cert-manager):

```yaml
gateway:
  domain: 127.0.0.1.sslip.io
  tls:
    issuer: kadras-ca-issuer
```
