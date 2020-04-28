# Connect to your Vault instance
provider "vault" {
  address      = var.vault
  token        = var.token
  ca_cert_file = "/Users/patrickschulz/OneDrive/GitHub/Vault/TLS/ca.crt.pem"
}

# Create the first level of Namespaces
resource "vault_namespace" "customer_main_namespace" {
  path = "customer"
}

# Added timer just to ensure proper deletion
resource "null_resource" "delay" {
  depends_on = [vault_namespace.customer_main_namespace]
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 5"
  }
}

# Enable userpass auth method to avoid the need for having external IdP like AD/Okta/etc. in place
resource "vault_auth_backend" "root_userpass" {
  depends_on = [vault_namespace.customer_main_namespace]
  type       = "userpass"
  path       = "userpass"
}

# Create a bunch of usersers in the userpass auth method
resource "vault_generic_endpoint" "vault_admin" {
  depends_on           = [vault_auth_backend.root_userpass]
  for_each             = var.admin
  path                 = "auth/userpass/users/${each.key}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "password": "changeme"
}
EOT
}

# Create policies for each desired role
resource "vault_policy" "vault_root" {
  name   = "vault_root"
  policy = file("${path.module}/policies/vault_root.hcl")
}

resource "vault_policy" "vault_audit" {
  name   = "vault_audit"
  policy = file("${path.module}/policies/vault_audit.hcl")
}

resource "vault_policy" "vault_ops" {
  name   = "vault_ops"
  policy = file("${path.module}/policies/vault_ops.hcl")
}

resource "vault_policy" "vault_key_ops" {
  name   = "vault_key_ops"
  policy = file("${path.module}/policies/vault_key_ops.hcl")
}

# Create entities inside the Vault Identity seceret engine and associate required policies
resource "vault_identity_entity" "vault_root" {
  depends_on = [vault_generic_endpoint.vault_admin]
  name       = lookup(var.admin, "peter")
  policies   = ["vault_root"]
  metadata = {
    namespace = "vault_root"
  }
}

resource "vault_identity_entity" "vault_audit" {
  depends_on = [vault_generic_endpoint.vault_admin]
  name       = lookup(var.admin, "moby")
  policies   = ["vault_audit"]
  metadata = {
    namespace = "vault_audit"
  }
}

resource "vault_identity_entity" "vault_ops" {
  depends_on = [vault_generic_endpoint.vault_admin]
  name       = lookup(var.admin, "bob")
  policies   = ["vault_ops"]
  metadata = {
    namespace = "vault_ops"
  }
}

resource "vault_identity_entity" "vault_key_ops" {
  depends_on = [vault_generic_endpoint.vault_admin]
  name       = lookup(var.admin, "alice")
  policies   = ["vault_key_ops"]
  metadata = {
    namespace = "vault_key_ops"
  }
}
