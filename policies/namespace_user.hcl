
# Manage namespaces
path "sys/namespaces/*" {
   capabilities = ["read", "list"]
}

# Manage Secrets
path "secrets/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}