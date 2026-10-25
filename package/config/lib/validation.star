load("@ytt:regexp", "regexp")

# Validation helpers used by the values schema.
# They must not depend on data values, since they run while the schema is evaluated.

_dns_label = "[a-z0-9]([-a-z0-9]*[a-z0-9])?"

def is_dns_name(value):
  return regexp.match("^" + _dns_label + "(\\." + _dns_label + ")*$", value)
end

def is_hours(value):
  return regexp.match("^[1-9][0-9]*h$", value)
end

def hours(value):
  return int(value[:-1])
end

# An OTLP/gRPC endpoint served by an in-cluster Service, with an optional `http://` scheme.
# Examples: `otel-collector.observability:4317`, `http://otel-collector.observability.svc.cluster.local:4317`.
def is_in_cluster_otlp_endpoint(value):
  return regexp.match("^(http://)?" + _dns_label + "\\." + _dns_label + "(\\.svc(\\.cluster\\.local)?)?:[0-9]{1,5}$", value)
end
