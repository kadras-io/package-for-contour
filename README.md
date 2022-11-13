# Contour

This project provides a [Carvel package](https://carvel.dev/kapp-controller/docs/latest/packaging) for [Contour](https://github.com/projectcontour/contour), an Envoy-based ingress controller.

## Components

* Contour
* Envoy

## Prerequisites

* Install the [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI to manage Carvel packages in a convenient way.
* Ensure [kapp-controller](https://carvel.dev/kapp-controller) is deployed in your Kubernetes cluster. You can do that with Carvel
[`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml
```

## Installation

You can install the Contour package directly or rely on the [Kadras package repository](https://github.com/arktonix/carvel-packages)
(recommended choice).

Follow the [instructions](https://github.com/arktonix/carvel-packages) to add the Kadras package repository to your Kubernetes cluster.

If you don't want to use the Kadras package repository, you can create the necessary `PackageMetadata` and
`Package` resources for the Contour package directly.

```shell
kubectl create namespace carvel-packages
kapp deploy -a contour-package -n carvel-packages -y \
    -f https://github.com/arktonix/package-for-contour/releases/latest/download/metadata.yml \
    -f https://github.com/arktonix/package-for-contour/releases/latest/download/package.yml
```

Either way, you can then install the Contour package using [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl).

```shell
kctrl package install -i contour \
    -p contour.packages.kadras.io \
    -v 1.23.0-kadras.1 \
    -n carvel-packages
```

You can retrieve the list of available versions with the following command.

```shell
kctrl package available list -p contour.packages.kadras.io
```

You can check the list of installed packages and their status as follows.

```shell
kctrl package installed list -n carvel-packages
```

## Configuration

The Contour package has the following configurable properties.

| Config | Default | Description |
|--------|---------|-------------|
| `infrastructureProvider` | (none) | The underlying infrastructure provider. Optional, used for validating & defaulting other configuration values on specific platforms. Valid values are `aws`, `azure`, `docker` and `vsphere`. |
| `namespace` | `projectcontour` | The namespace in which to deploy Contour and Envoy. |
| `contour.configFileContents` | (none) | The YAML contents of the Contour config file. See [the Contour configuration documentation](https://projectcontour.io/docs/latest/configuration/#configuration-file) for more information. |
| `contour.replicas` | `2` | How many Contour pod replicas to have. |
| `contour.useProxyProtocol` | `false` | Whether to enable PROXY protocol for all Envoy listeners. |
| `contour.logLevel` | `info` | The Contour log level. Valid values are `info` and `debug`. |
| `envoy.service.type` | `NodePort` for docker and vsphere; `LoadBalancer` for others | The type of Kubernetes service to provision for Envoy. Valid values are `LoadBalancer`, `NodePort`, and `ClusterIP`. |
| `envoy.service.externalTrafficPolicy` | `Cluster` for vsphere; `Local` for others | The external traffic policy for the Envoy service. Valid values are `Local` and `Cluster`.  If `envoy.service.type` is `ClusterIP`, this field is ignored. |
| `envoy.service.loadBalancerIP` | (none) | The desired load balancer IP for the Envoy service. If `envoy.service.type` is not `LoadBalancer`, this field is ignored. |
| `envoy.service.annotations` | (none) | Annotations to set on the Envoy service. |
| `envoy.service.nodePorts.http` | (none) | If `envoy.service.type` == `NodePort` or `LoadBalancer`, the node port number to expose Envoy's HTTP listener on. If not specified, a node port will be auto-assigned by Kubernetes. |
| `envoy.service.nodePorts.https` | (none) | If `envoy.service.type` == `NodePort` or `LoadBalancer`, the node port number to expose Envoy's HTTPS listener on. If not specified, a node port will be auto-assigned by Kubernetes. |
| `envoy.service.aws.loadBalancerType` | (none) | If `infrastructureProvider` == `aws`, the type of AWS load balancer to provision. Valid values are `classic` and `nlb`. If `infrastructureProvider` is not `aws`, this field is ignored. |
| `envoy.hostPorts.enable` | `false` | Whether to enable host ports for the Envoy pods. If false, `envoy.hostPorts.http` and `envoy.hostPorts.https` are ignored. |
| `envoy.hostPorts.http` | `80` | If `envoy.hostPorts.enable` == true, the host port number to expose Envoy's HTTP listener on. |
| `envoy.hostPorts.https` | `443` | If `envoy.hostPorts.enable` == true, the host port number to expose Envoy's HTTPS listener on. |
| `envoy.hostNetwork` | `false` | Whether to enable host networking for the Envoy pods. |
| `envoy.terminationGracePeriodSeconds` | `300` | The termination grace period, in seconds, for the Envoy pods. |
| `envoy.logLevel` | `info` | The Envoy log level. Valid values are `trace`, `debug`, `info`, `warn`, `error`, `critical`, and `off`. |
| `certificates.useCertManager` | `false` | Whether to use cert-manager to provision TLS certificates for securing communication between Contour and Envoy. If false, the upstream Contour certgen job will be used to provision certificates. If true, the `cert-manager` addon must be installed in the cluster. |
| `certificates.duration` | `8760h` |  If using cert-manager, how long the certificates should be valid for. If useCertManager is false, this field is ignored. |
| `certificates.renewBefore` | `360h` |  If using cert-manager, how long before expiration the certificates should be renewed. If useCertManager is false, this field is ignored. |

You can define your configuration in a `values.yml` file.

```yaml
namespace: projectcontour

envoy:
  service:
    type: ClusterIP
```

Then, reference it from the `kctrl` command when installing or upgrading the package.

```shell
kctrl package install -i contour \
    -p contour.packages.kadras.io \
    -v 1.23.0-kadras.1 \
    -n carvel-packages \
    --values-file values.yml
```

### Application configuration values

Within the data values file, the `contour.configFileContents` field may optionally contain YAML to put directly in the Contour config file.
See [the Contour configuration documentation](https://projectcontour.io/docs/latest/configuration/#configuration-file) for full details on the available options.

An example data values file that specifies this field looks like:

```yaml
contour:
  configFileContents:
    accesslog-format: json
```

#### Multi-cloud configuration steps

If deploying Contour to **AWS**, you may optionally configure the package to provision a Network Load Balancer (NLB) instead of the default Classic Load Balancer by providing the following data values:

```yaml
infrastructureProvider: aws
envoy:
  service:
    aws:
      loadBalancerType: nlb
```

You may specify platform-specific annotations to be added to the Envoy service by providing the following data values:

```yaml
envoy:
  service:
    annotations:
      annotation-key-1: val-1
      ...
```

## Documentation

For documentation specific to Contour, check out [projectcontour.io](https://projectcontour.io).

## References

This package is based on the original Contour package used in [Tanzu Community Edition](https://github.com/vmware-tanzu/community-edition) before its retirement.

## Supply Chain Security

This project is compliant with level 2 of the [SLSA Framework](https://slsa.dev).

<img src="https://slsa.dev/images/SLSA-Badge-full-level2.svg" alt="The SLSA Level 2 badge" width=200>
