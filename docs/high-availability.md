# Configuring High Availability

High availability for the Contour components can be configured using different strategies.

## Contour

The Contour component supports high availability following an active/passive model based on the leader election strategy. You can customize the number of replicas for the Contour Pod.

```yaml
contour:
  replicas: 2
```

The leader election strategy is enabled by default and can be customized via the `contour.configMapData` property.

```yaml
contour:
  configMapData:
    leaderelection:
      configmap-namespace: "projectcontour"
```

For more information, check the Contour documentation for the [leader election configuration](https://projectcontour.io/docs/latest/configuration/#leader-election-configuration).

## Envoy

When Envoy is deployed as a `DaemonSet`, each node will have an instance. When it's deployed as a `Deployment`, you can customize the number of replicas.

```yaml
envoy:
  workload:
    type: Deployment
    replicas: 2
```
