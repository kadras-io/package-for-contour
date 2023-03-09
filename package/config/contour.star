load("@ytt:assert", "assert")
load("@ytt:data", "data")
load("@ytt:struct", "struct")

# ########
# CONTOUR
# ########

def get_contour_deployment_args():
  args = [
    "serve",
    "--incluster",
    "--xds-address=::",
    "--xds-port=8001",
    "--stats-address=::",
    "--http-address=::",
    "--health-address=::",
    "--envoy-service-http-address=::",
    "--envoy-service-http-port=" + str(get_envoy_container_port_http()),
    "--envoy-service-https-address=::",
    "--envoy-service-https-port=" + str(get_envoy_container_port_https()),
    "--contour-cafile=/certs/ca.crt",
    "--contour-cert-file=/certs/tls.crt",
    "--contour-key-file=/certs/tls.key",
    "--config-path=/config/contour.yaml",
    "--log-format=" + data.values.contour.config.logFormat
  ]
  
  if data.values.contour.config.useProxyProtocol:
    args.append("--use-proxy-protocol")
  end

  if data.values.contour.config.logLevel == "debug":
    args.append("--debug")
  end

  return args
end

# ######
# ENVOY
# ######

def get_envoy_container_port_http():
  if data.values.envoy.workload.hostNetwork:
    return data.values.envoy.workload.hostPorts.http
  else:
    return 8080
  end
end

def get_envoy_container_port_https():
  if data.values.envoy.workload.hostNetwork:
    return data.values.envoy.workload.hostPorts.https
  else:
    return 8443
  end
end

def get_envoy_service_type():
  if data.values.envoy.service.type:
    return data.values.envoy.service.type
  elif data.values.infrastructureProvider == "local":
    return "NodePort"
  elif data.values.infrastructureProvider == "vsphere":
    return "NodePort"
  else:
    return "LoadBalancer"
  end
end

def get_envoy_service_external_traffic_policy():
  if data.values.envoy.service.externalTrafficPolicy:
    return data.values.envoy.service.externalTrafficPolicy
  elif data.values.infrastructureProvider == "vsphere":
    return "Cluster"
  else:
    return "Local"
  end
end

def get_envoy_service_annotations():
  annotations = {}

  if data.values.infrastructureProvider == "aws":
    if data.values.envoy.service.aws.loadBalancerType == "nlb":
      annotations["service.beta.kubernetes.io/aws-load-balancer-type"] = "nlb"
    else:
      # This annotation puts the AWS ELB into "TCP" mode so that it does not
      # do HTTP negotiation for HTTPS connections at the ELB edge.
      # The downside of this is the remote IP address of all connections will
      # appear to be the internal address of the ELB. That's why we enable
      # the PROXY protocol on the ELB to recover the original remote IP address
      # via another annotation.
      annotations["service.beta.kubernetes.io/aws-load-balancer-backend-protocol"] = "tcp"
      annotations["service.beta.kubernetes.io/aws-load-balancer-proxy-protocol"] = "*"
    end
  end

  if data.values.envoy.service.annotations:
    annotations_kvs = struct.decode(data.values.envoy.service.annotations)
    annotations.update(annotations_kvs)
  end

  return annotations
end
