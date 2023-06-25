# Installing Contour on kind

First, create a kind cluster with the necessary configuration to expose ports 80 and 443.

```shell
kind create cluster --config test/setup/kind/local/kind-config.yml
```

Then, configure Contour to deploy Envoy as a `ClusterIP` Service.

```yaml
envoy:
  service:
    type: ClusterIP
```

For more information, refer to the dedicated Contour [documentation](https://projectcontour.io/docs/latest/guides/kind/).
