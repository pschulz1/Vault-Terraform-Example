# List audit backends
path "/sys/audit" {
  capabilities = ["read","list"]
}

# Remove audit devices
path "/sys/audit/*" {
  capabilities = ["delete"]
}

# Hash values to compare with audit logs
path "/sys/audit-hash/*" {
  capabilities = ["create"]
}

# Read HMAC configuration for redacting headers
path "/sys/config/auditing/request-headers" {
  capabilities = ["read", "sudo"]
}

# Configure HMAC for redacting headers
path "/sys/config/auditing/request-headers/*" {
  capabilities = ["read", "list", "create", "update", "sudo"]
}

# Get Storage Key Status
path "/sys/key-status" {
  capabilities = ["read"]
}

# Create an audit backend. Operators are not allowed to remove them.
path "/sys/audit/*" {
  capabilities = ["create","read","list","sudo"]
}

# List Authentication Backends
path "/sys/auth" {
  capabilities = ["read","list"]
}

# Hash values to compare with audit logs
path "/sys/audit-hash/*" {
  capabilities = ["create"]
}