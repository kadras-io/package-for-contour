# Contour

![Test Workflow](https://github.com/kadras-io/package-for-contour/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-contour/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package for [Contour](https://projectcontour.io), a high performance ingress controller for Kubernetes based on Envoy.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.32+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
  ```

### Installation

Add the Kadras [package repository](https://github.com/kadras-io/kadras-packages) to your Kubernetes cluster:

  ```shell
  kctrl package repository add -r kadras-packages \
    --url ghcr.io/kadras-io/kadras-packages \
    -n kadras-system --create-namespace
  ```

<details><summary>Installation without package repository</summary>
The recommended way of installing the Contour package is via the Kadras <a href="https://github.com/kadras-io/kadras-packages">package repository</a>. If you prefer not using the repository, you can add the package definition directly using <a href="https://carvel.dev/kapp/docs/latest/install"><code>kapp</code></a> or <code>kubectl</code>.

  ```shell
  kubectl create namespace kadras-system
  kapp deploy -a contour-package -n kadras-system -y \
    -f https://github.com/kadras-io/package-for-contour/releases/latest/download/metadata.yml \
    -f https://github.com/kadras-io/package-for-contour/releases/latest/download/package.yml
  ```
</details>

Install the Contour package:

  ```shell
  kctrl package install -i contour \
    -p contour.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-system
  ```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
>   ```shell
>   kctrl package available list -p contour.packages.kadras.io -n kadras-system
>   ```

Verify the installed packages and their status:

  ```shell
  kctrl package installed list -n kadras-system
  ```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to Contour, check out [projectcontour.io](https://projectcontour.io).

## 🎯&nbsp; Configuration

The Contour package can be customized via a `values.yml` file.

  ```yaml
  contour:
    config:
      logFormat: json
      useProxyProtocol: true
  ```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

  ```shell
  kctrl package install -i contour \
    -p contour.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-system \
    --values-file values.yml
  ```

### Values

The Contour package has the following configurable properties.

<details><summary>Configurable properties</summary>

| Config | Default | Description |
|--------|---------|-------------|
| `namespace` | `projectcontour` | The namespace in which to deploy Contour and Envoy. |

Settings for the Contour component.

| Config | Default | Description |
|--------|---------|-------------|
| `contour.replicas` | `2` | The number of Contour replicas. In order to enable high availability, it should be greater than 1. |
| `contour.config.logFormat` | `text` | Log output format for Contour. Either `text` (default) or `json`. |
| `contour.config.logLevel` | `info` | The Contour log level. Valid options are `info` and `debug`. |
| `contour.config.useProxyProtocol` | `false` | Whether to enable PROXY protocol for all Envoy listeners. |
| `contour.configMapData` | `""` | The YAML contents of the `contour` ConfigMap. See https://projectcontour.io/docs/latest/configuration/#configuration-file for more information. |

Settings for the Envoy component.

| Config | Default | Description |
|--------|---------|-------------|
| `envoy.workload.type` | `DaemonSet` | The type of Kubernetes workload that Envoy is deployed as. Options are `Deployment` or `DaemonSet`. |
| `envoy.workload.replicas` | `2` | The number of Envoy replicas to deploy when `type` is set to `Deployment`. |
| `envoy.workload.hostPorts.enabled` | `true` | Whether to enable host ports. If false, `http` & `https` are ignored. |
| `envoy.workload.hostPorts.http` | `80` | If enabled, the host port number to expose Envoy's HTTP listener on. |
| `envoy.workload.hostPorts.https` | `443` | If enabled, the host port number to expose Envoy's HTTPS listener on. |
| `envoy.workload.hostNetwork` | `false` | Whether to enable host networking for the Envoy pods. |
| `envoy.workload.terminationGracePeriodSeconds` | `300` | The termination grace period, in seconds, for the Envoy pods. |
| `envoy.config.logLevel` | `info` | The Envoy log level. |
| `envoy.service.type` | `LoadBalancer` | The type of Kubernetes service to provision for Envoy. |
| `envoy.service.loadBalancerIP` | `""` | The desired load balancer IP. If `type` is not `LoadBalancer', this field is ignored. It is up to the cloud provider whether to honor this request. If not specified, the load balancer IP will be assigned by the cloud provider. |
| `envoy.service.externalTrafficPolicy` | `Local` | The external traffic policy for the Envoy service. |
| `envoy.service.annotations` | `false` | Annotations to set on the Envoy service. |
| `envoy.service.nodePorts.http` | `false` | The node port number to expose Envoy's HTTP listener on. If not specified, a node port will be auto-assigned by Kubernetes. |
| `envoy.service.nodePorts.https` | `false` | The node port number to expose Envoy's HTTPS listener on. If not specified, a node port will be auto-assigned by Kubernetes. |

TLS configuration to secure the communication between Contour and Envoy.

| Config | Default | Description |
|--------|---------|-------------|
| `certificates.useCertManager` | `false` | Whether to use cert-manager to provision TLS certificates for securing the communication between Contour and Envoy. If `false`, the `contour-certgen` Job will be used to provision certificates. If `true`, cert-manager must be installed in the cluster. See: https://github.com/kadras-io/package-for-cert-manager. |
| `certificates.duration` | `8760h` | If using cert-manager, how long the certificates should be valid for. If `useCertManager` is false, this field is ignored. |
| `certificates.renewBefore` | `360h` | If using cert-manager, how long before expiration the certificates should be renewed. If `useCertManager` is false, this field is ignored. |

</details>

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.

## 🙏&nbsp; Acknowledgments

This package is inspired by the original Contour package used in the [Tanzu Community Edition](https://github.com/vmware-tanzu/community-edition) project before its retirement.
