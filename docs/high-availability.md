# High Availability

By default, the package runs 2 replicas of Contour and 2 replicas of Envoy, spread across nodes on a best-effort basis. The defaults also work on single-node clusters.

## Contour

Contour follows an active/passive model: one replica is elected leader and writes status updates, while all replicas serve configuration to Envoy.

```yaml
contour:
  replicas: 2
```

## Envoy

Envoy runs as a Deployment by default, with a configurable number of replicas.

```yaml
envoy:
  kind: Deployment
  replicas: 3
```

Alternatively, Envoy can run as a DaemonSet, with one replica on every node. That's useful when exposing Envoy on host ports (see [local.md](local.md)).

```yaml
envoy:
  kind: DaemonSet
```

Switching between `Deployment` and `DaemonSet` creates the new workload before deleting the old one, to avoid downtime.

## Disruptions

With more than one replica, a PodDisruptionBudget keeps at least one Contour and one Envoy replica available during voluntary disruptions, like node drains. When Envoy runs as a DaemonSet, its rolling update strategy plays the same role.

When an Envoy Pod terminates, it stops accepting new connections and drains the open ones for up to `envoy.termination_grace_period_seconds` (default: 300). See [Envoy container draining](https://projectcontour.io/docs/latest/troubleshooting/envoy-container-draining).

## Resources

The package sets conservative resource requests. Tune them for your traffic with a ytt overlay, as described in [configuration.md](configuration.md#resources).
