# AWS

Special configuration when deploying Contour on AWS.

## Classic Load Balancer

When deploying this package to AWS, a [Classic Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/introduction.html) will be provisioned by default for the Envoy Service. You can configure the load balancer by specifying the necessary annotations.

```yaml
envoy:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
```

## Network Load Balancer

You can configure the package to provision an AWS Network Load Balancer (NLB) instead of the default Classic Load Balancer for the Envoy Service.

```yaml
envoy:
  workload:
    hostNetwork: true
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
```

In order to use NLBs, the AWS Load Balancer Controller must be installed in your cluster. Follow the [installation instructions](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html).

For more information on the host network configuration, refer to the dedicated Contour [documentation](https://projectcontour.io/docs/latest/deploy-options/#host-networking).

Refer to the AWS Load Balancer Controller [documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/service/annotations/) for the full list of supported annotations.

If you want to configure the TLS termination on the NLB, refer to the dedicated Contour [documentation](https://projectcontour.io/docs/latest/guides/deploy-aws-tls-nlb/).

For additional information about load balancers on AWS, you can refer to these resources:

* [Overview about network load balancing in AWS](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)
* [NLB support in the AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/service/nlb/)
