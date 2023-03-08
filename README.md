# Contour

![Test Workflow](https://github.com/kadras-io/package-for-contour/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-contour/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v0.1/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Twitter](https://img.shields.io/static/v1?label=Twitter&message=Follow&color=1DA1F2)](https://twitter.com/kadrasIO)

A Carvel package for [Contour](https://projectcontour.io), a high performance ingress controller for Kubernetes based on Envoy.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.24+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
  ```

### Installation

Add the Kadras [package repository](https://github.com/kadras-io/kadras-packages) to your Kubernetes cluster:

  ```shell
  kubectl create namespace kadras-packages
  kctrl package repository add -r kadras-packages \
    --url ghcr.io/kadras-io/kadras-packages \
    -n kadras-packages
  ```

<details><summary>Installation without package repository</summary>
The recommended way of installing the Contour package is via the Kadras <a href="https://github.com/kadras-io/kadras-packages">package repository</a>. If you prefer not using the repository, you can add the package definition directly using <a href="https://carvel.dev/kapp/docs/latest/install"><code>kapp</code></a> or <code>kubectl</code>.

  ```shell
  kubectl create namespace kadras-packages
  kapp deploy -a contour-package -n kadras-packages -y \
    -f https://github.com/kadras-io/package-for-contour/releases/latest/download/metadata.yml \
    -f https://github.com/kadras-io/package-for-contour/releases/latest/download/package.yml
  ```
</details>

Install the Contour package:

  ```shell
  kctrl package install -i contour \
    -p contour.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-packages
  ```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
>   ```shell
>   kctrl package available list -p contour.packages.kadras.io -n kadras-packages
>   ```

Verify the installed packages and their status:

  ```shell
  kctrl package installed list -n kadras-packages
  ```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to Contour, check out [projectcontour.io](https://projectcontour.io).

## 🎯&nbsp; Configuration

The Contour package can be customized via a `values.yml` file.

  ```yaml
  namespace: projectcontour

  envoy:
    service:
      type: ClusterIP
  ```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

  ```shell
  kctrl package install -i contour \
    -p contour.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-packages \
    --values-file values.yml
  ```

### Values

The Contour package has the following configurable properties.

<details><summary>Configurable properties</summary>

| Config | Default | Description |
|--------|---------|-------------|
| `infrastructureProvider` | (none) | The underlying infrastructure provider. Optional, used for validating & defaulting other configuration values on specific platforms. Valid values are `aws`, `azure`, `local` and `vsphere`. |
| `namespace` | `projectcontour` | The namespace in which to deploy Contour and Envoy. |
| `contour.configFileContents` | (none) | The YAML contents of the Contour config file. See [the Contour configuration documentation](https://projectcontour.io/docs/latest/configuration/#configuration-file) for more information. |
| `contour.replicas` | `2` | How many Contour pod replicas to have. |
| `contour.useProxyProtocol` | `false` | Whether to enable PROXY protocol for all Envoy listeners. |
| `contour.logLevel` | `info` | The Contour log level. Valid values are `info` and `debug`. |
| `envoy.service.type` | `NodePort` for local and vsphere; `LoadBalancer` for others | The type of Kubernetes service to provision for Envoy. Valid values are `LoadBalancer`, `NodePort`, and `ClusterIP`. |
| `envoy.service.externalTrafficPolicy` | `Cluster` for vsphere; `Local` for others | The external traffic policy for the Envoy service. Valid values are `Local` and `Cluster`.  If `envoy.service.type` is `ClusterIP`, this field is ignored. |
| `envoy.service.loadBalancerIP` | (none) | The desired load balancer IP for the Envoy service. If `envoy.service.type` is not `LoadBalancer`, this field is ignored. |
| `envoy.service.annotations` | (none) | Annotations to set on the Envoy service. |
| `envoy.service.nodePorts.http` | (none) | If `envoy.service.type` == `NodePort` or `LoadBalancer`, the node port number to expose Envoy's HTTP listener on. If not specified, a node port will be auto-assigned by Kubernetes. |
| `envoy.service.nodePorts.https` | (none) | If `envoy.service.type` == `NodePort` or `LoadBalancer`, the node port number to expose Envoy's HTTPS listener on. If not specified, a node port will be auto-assigned by Kubernetes. |
| `envoy.service.aws.loadBalancerType` | (none) | If `infrastructureProvider` == `aws`, the type of AWS load balancer to provision. Valid values are `classic` and `nlb`. If `infrastructureProvider` is not `aws`, this field is ignored. |
| `envoy.hostPorts.enabled` | `false` | Whether to enable host ports for the Envoy pods. If false, `envoy.hostPorts.http` and `envoy.hostPorts.https` are ignored. |
| `envoy.hostPorts.http` | `80` | If `envoy.hostPorts.enable` == true, the host port number to expose Envoy's HTTP listener on. |
| `envoy.hostPorts.https` | `443` | If `envoy.hostPorts.enable` == true, the host port number to expose Envoy's HTTPS listener on. |
| `envoy.hostNetwork` | `false` | Whether to enable host networking for the Envoy pods. |
| `envoy.terminationGracePeriodSeconds` | `300` | The termination grace period, in seconds, for the Envoy pods. |
| `envoy.logLevel` | `info` | The Envoy log level. Valid values are `trace`, `debug`, `info`, `warn`, `error`, `critical`, and `off`. |
| `certificates.useCertManager` | `false` | Whether to use cert-manager to provision TLS certificates for securing communication between Contour and Envoy. If false, the upstream Contour certgen job will be used to provision certificates. If true, the `cert-manager` addon must be installed in the cluster. |
| `certificates.duration` | `8760h` |  If using cert-manager, how long the certificates should be valid for. If useCertManager is false, this field is ignored. |
| `certificates.renewBefore` | `360h` |  If using cert-manager, how long before expiration the certificates should be renewed. If useCertManager is false, this field is ignored. |

</details>

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

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.

## 🙏&nbsp; Acknowledgments

This package is based on the original Contour package used in the [Tanzu Community Edition](https://github.com/vmware-tanzu/community-edition) project before its retirement.
