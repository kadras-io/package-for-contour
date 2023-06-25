# Installing Contour on kind

First, create a kind cluster with the necessary configuration to expose ports 80 and 443.

```shell
kind create cluster --config test/setup/kind/local/kind-config.yml
```

Then, configure Contour for local deployment, which will deploy Envoy as a `NodePort` Service.

```yaml
infrastructure_provider: local
```

For more information, refer to the dedicated Contour [documentation](https://projectcontour.io/docs/latest/guides/kind/).
