# Rekey MEK
path "sys/rekey/" {
   capabilities = ["sudo", "update"]
}

# Rotate DEK
path "/sys/rotate" {
   capabilities = ["sudo", "update"]
}

# Get Storage Key Status
path "/sys/key-status" {
  capabilities = ["read"]
}

# Start root token generation
path "/sys/generate-root/attempt" {
  capabilities = ["read", "list", "create", "update", "delete"]
}

# Submit Key for Re-keying purposes
path "/sys/rekey-recovery-key/update" {
  capabilities = ["create", "update"]
}

# Verify update
path "/sys/rekey-recovery-key/verify" {
  capabilities = ["create", "update"]
}