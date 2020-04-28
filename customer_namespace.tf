
provider "vault" {
  address      = var.vault
  token        = var.token
  ca_cert_file = "/Users/patrickschulz/OneDrive/GitHub/Vault/TLS/ca.crt.pem"
  namespace    = "customer"
  alias        = "customer"
}

resource "vault_namespace" "customer_child_namespaces" {
  depends_on = [vault_namespace.customer_main_namespace, vault_auth_backend.userpass]
  provider   = vault.customer
  for_each   = toset(var.namespaces)
  path       = each.key
}

resource "vault_auth_backend" "userpass" {
  depends_on = [vault_namespace.customer_main_namespace]
  provider   = vault.customer
  type       = "userpass"
  path       = "userpass"
}

resource "vault_generic_endpoint" "user" {
  depends_on           = [vault_auth_backend.userpass]
  provider             = vault.customer
  for_each             = var.user
  path                 = "auth/userpass/users/${each.key}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "password": "changeme"
}
EOT
}

resource "vault_generic_endpoint" "admin" {
  depends_on           = [vault_auth_backend.userpass]
  provider             = vault.customer
  for_each             = var.admin
  path                 = "auth/userpass/users/${each.key}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "password": "changeme"
}
EOT
}

resource "vault_policy" "vault_admin" {
  depends_on = [vault_namespace.customer_child_namespaces]
  provider   = vault.customer
  name       = "vault_admin"
  policy     = file("${path.module}/policies/vault_admin.hcl")
}

resource "vault_identity_entity" "admin" {
  depends_on = [vault_generic_endpoint.admin]
  provider   = vault.customer
  for_each   = var.admin
  name       = each.value
  policies   = ["vault_admin"]
  metadata = {
    namespace = "admin"
  }
}

resource "vault_identity_entity_alias" "admin_alias" {
  provider       = vault.customer
  for_each       = var.admin
  name           = each.key
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.admin[each.key].id
}

resource "vault_identity_group" "admin_group" {
  provider          = vault.customer
  name              = "vault_admin"
  type              = "internal"
  policies          = ["vault_admin"]
  member_entity_ids = [for value in vault_identity_entity.admin : value.id]
  metadata = {
    version = "2"
  }
}

resource "vault_identity_entity" "user" {
  provider   = vault.customer
  depends_on = [vault_generic_endpoint.user]
  for_each   = var.user
  name       = each.value
  metadata = {
    namespace = "user"
  }
}

resource "vault_identity_entity_alias" "user_alias" {
  provider       = vault.customer
  for_each       = var.user
  name           = each.key
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.user[each.key].id
}

resource "vault_identity_group" "user_group" {
  provider          = vault.customer
  name              = "vault_user"
  type              = "internal"
  member_entity_ids = [for value in vault_identity_entity.user : value.id]
  metadata = {
    version = "2"
  }
}
