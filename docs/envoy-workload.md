# Configuring the Envoy Workload

The Envoy workload can be deployed as a `DaemonSet` or as a Deployment. The recommended (and default) installation is as a `DaemonSet`.

```yaml
envoy:
  workload:
    type: DaemonSet
```

An alternative model utilizes a `Deployment`.

```yaml
envoy:
  workload:
    type: Deployment
```

For more information on the use cases for each model, check the Contour documentation for [deployment options](https://projectcontour.io/docs/latest/deploy-options).
