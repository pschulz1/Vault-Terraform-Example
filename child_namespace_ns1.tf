provider "vault" {
  address      = var.vault
  token        = var.token
  ca_cert_file = "/Users/patrickschulz/OneDrive/GitHub/Vault/TLS/ca.crt.pem"
  namespace    = "customer/ns1"
  alias        = "ns1"
}

resource "vault_policy" "namespace_admin" {
  depends_on = [vault_namespace.customer_child_namespaces]
  provider   = vault.ns1
  name       = "namespace_admin"
  policy     = file("${path.module}/policies/namespace_admin.hcl")
}

resource "vault_policy" "namespace_user" {
  depends_on = [vault_namespace.customer_child_namespaces]
  provider   = vault.ns1
  name       = "namespace_user"
  policy     = file("${path.module}/policies/namespace_user.hcl")
}

resource "vault_identity_group" "namespace_admin" {
  depends_on = [vault_identity_group.admin_group, vault_namespace.customer_child_namespaces]
  provider   = vault.ns1
  name       = "namespace_admin"
  type       = "internal"
  policies   = ["namespace_admin"]
  # member_entity_ids = [for value in vault_identity_entity.admin : value.id]
  member_group_ids = [vault_identity_group.admin_group.id]
  metadata = {
    version = "2"
  }
}

resource "vault_identity_group" "namespace_user" {
  depends_on = [vault_identity_group.admin_group, vault_namespace.customer_child_namespaces]
  provider   = vault.ns1
  name       = "namespace_user"
  type       = "internal"
  policies   = ["default", "namespace_user"]
  # member_entity_ids = [for value in vault_identity_entity.user : value.id]
  member_group_ids = [vault_identity_group.user_group.id]
  metadata = {
    version = "2"
  }
}

resource "vault_mount" "kv" {
  depends_on  = [vault_namespace.customer_child_namespaces]
  provider    = vault.ns1
  path        = "secrets"
  type        = "kv"
  description = "This is an example mount"
}

resource "vault_generic_secret" "example" {
  depends_on = [vault_mount.kv, vault_namespace.customer_child_namespaces]
  provider   = vault.ns1
  path       = "secrets/foo"

  data_json = <<EOT
{
  "foo":   "bar",
  "pizza": "cheese"
}
EOT
}
