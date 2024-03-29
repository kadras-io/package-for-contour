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
  if data.values.infrastructure_provider == "local":
    return "NodePort"
  elif data.values.infrastructure_provider == "vsphere":
    return "NodePort"
  else:
    return data.values.envoy.service.type
  end
end

def get_envoy_service_external_traffic_policy():
  if data.values.infrastructure_provider == "vsphere":
    return "Cluster"
  else:
    return data.values.envoy.service.externalTrafficPolicy
  end
end

def get_envoy_service_annotations():
  annotations = {}

  if data.values.envoy.service.annotations:
    annotations_kvs = struct.decode(data.values.envoy.service.annotations)
    annotations.update(annotations_kvs)
  end

  return annotations
end
