# DR/Perf. Replication
path "/sys/replication/*" {
   capabilities = ["sudo", "update", "create", "delete", "list"]
}

# Configure License
path "/sys/license" {
  capabilities = ["read", "list", "create", "update", "delete"]
}

#Get Cluster Leader
path "/sys/leader" {
  capabilities = ["read"]
}

