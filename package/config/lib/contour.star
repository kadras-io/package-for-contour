load("@ytt:data", "data")
load("@ytt:struct", "struct")
load("/lib/validation.star", "hours")

# ########
# CONTOUR
# ########

def contour_args():
  args = [
    "serve",
    "--incluster",
    "--xds-address=0.0.0.0",
    "--xds-port=8001",
    "--contour-cafile=/certs/ca.crt",
    "--contour-cert-file=/certs/tls.crt",
    "--contour-key-file=/certs/tls.key",
    "--config-path=/config/contour.yaml",
    "--log-format=" + data.values.observability.logging.format,
  ]

  if data.values.envoy.proxy_protocol:
    args.append("--use-proxy-protocol")
  end

  #! Contour only distinguishes between the default (info) level and debug.
  if data.values.observability.logging.level == "debug":
    args.append("--debug")
  end

  return args
end

# The configuration computed from the package values. `contour.config` is merged on top of it.
def contour_config():
  config = {
    "tls": {
      "minimum-protocol-version": "1.3",
    },
    "accesslog-format": "json" if data.values.observability.logging.format == "json" else "envoy",
  }

  if data.values.gateway.enabled:
    config["gateway"] = {
      "gatewayRef": {
        "namespace": data.values.namespace,
        "name": data.values.gateway.name,
      },
    }
  end

  if data.values.observability.tracing.enabled:
    collector = tracing_collector()
    config["tracing"] = {
      "extensionService": collector.namespace + "/" + tracing_extension_service_name,
      "serviceName": "contour",
      "overallSampling": str(sampling_percentage()),
    }
  end

  return config
end

# ######
# ENVOY
# ######

def envoy_log_level():
  return data.values.observability.logging.level
end

# ####
# TLS
# ####

def is_cert_manager():
  return data.values.tls.internal.provider == "cert-manager"
end

def certgen_lifetime_days():
  days = hours(data.values.tls.internal.duration) // 24
  return days if days > 0 else 1
end

# ########
# GATEWAY
# ########

def gateway_tls_enabled():
  return data.values.gateway.enabled and data.values.gateway.tls.issuer != ""
end

def gateway_tls_secret_name():
  return data.values.gateway.name + "-tls"
end

# ########
# TRACING
# ########

tracing_extension_service_name = "contour-tracing"

# Splits an endpoint like `http://otel-collector.observability.svc:4317` into its Service coordinates.
def tracing_collector():
  endpoint = data.values.observability.tracing.endpoint
  if endpoint.startswith("http://"):
    endpoint = endpoint[len("http://"):]
  end
  host, port = endpoint.rsplit(":", 1)
  labels = host.split(".")
  return struct.encode({"name": labels[0], "namespace": labels[1], "port": int(port)})
end

def sampling_percentage():
  return int(data.values.observability.tracing.sampling_rate * 10000 + 0.5) / 100.0
end
