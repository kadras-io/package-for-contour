load("@ytt:assert", "assert")
load("@ytt:data", "data")
load("@ytt:struct", "struct")

# ########
# CONTOUR
# ########

def get_contour_deployment_args():
  args = [
    "serve",
    "--config-path=/config/contour.yaml",
    "--incluster",
    "--xds-address=::",
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
