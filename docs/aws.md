# AWS

Special configuration when deploying Contour on AWS.

## Classic Load Balancer

When deploying this package to AWS, a Classic Load Balancer will be provisioned by default for the Envoy Service.

## Network Load Balancer

You can configure the package to provision an AWS Network Load Balancer (NLB) instead of the default Classic Load Balancer.

```yaml
envoy:
  infrastructure_provider: aws
  workload:
    hostNetwork: true
    dnsPolicy: ClusterFirstWithHostNet
  service:
    aws:
      loadBalancerType: nlb
```

For more information on the host network configuration, refer to the dedicated Contour [documentation](https://projectcontour.io/docs/latest/deploy-options/#host-networking).

In order to use NLBs, the AWS Load Balancer Controller must be installed in your cluster. Follow the [installation instructions](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html).

When the NLB type is configured, the package adds the following annotations to the Envoy service.

```text
service.beta.kubernetes.io/aws-load-balancer-type=external
service.beta.kubernetes.io/aws-load-balancer-nlb-target-type=ip
service.beta.kubernetes.io/aws-load-balancer-scheme=internet-facing
```

You can overwrite any of those annotations or add new ones via the `envoy.service.annotations` configuration group. Refer to the AWS Load Balancer Controller [documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/service/annotations/) for the full list of supported annotations.

```yaml
envoy:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: instance
      service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout: 10
```

If you want to configure the TLS termination on the NLB, refer to the dedicated Contour [documentation](https://projectcontour.io/docs/latest/guides/deploy-aws-tls-nlb/).

For additional information about load balancers on AWS, you can refer to these resources:

* [Overview about network load balancing in AWS](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)
* [NLB support in the AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/service/nlb/)

## Proxy Protocol

Depending on the load balancer configuration for AWS, it might be that the remote IP address is not forwarded to the Envoy Pods. The PROXY protocol can be enabled to achieve that.

```yaml
contour:
  config:
    useProxyProtocol: true
```

For example, you'll need this configuration when using the AWS Classic Load Balancer. You can find more information in the dedicated Contour [documentation](https://projectcontour.io/docs/latest/guides/proxy-proto/).
