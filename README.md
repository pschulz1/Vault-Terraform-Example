# Manage Vault Namespaces & Identities via Terraform

This repository is intented as an example, of how one can manage Vault Namespaces, Identities, Authentication Methods, etc. via Terraform.

### Prerequisites

You will need a running Vault server or alternatively you can spin up a Vault server in dev mode:
```
vault server -dev
```
For more please see: https://learn.hashicorp.com/vault/getting-started/dev-server

### Using the code

All you have to do, is up update some variables to point to your Vault server:

* "vault" --> Like https://vault:8200 (you might need to use http in case you've disabled TLS) 
* "token" --> Your Vault Token


## Running the code

```
terraform init
```
```
terraform plan
```
```
terraform apply
```

Thats it.

### What this code will do for you

The idea started with a few customer questions: 

* What is the best approach to manage namespaces?
* Manage auth methos centrally and using identities vs. enabling auth method per namespace?
* What is the best approach of creating policies, centrally inside the root namespace (not recommended) or inside the respective namespace?

This is work in progress and just for training purposes.


```

Inside the root namespace

* Creates a single namespace called "customer", with the idea that at the root namespace level, only operations should be performed, which are technically related to it. Such as re-key, rotate, etc. At this level only policies should be created which are needed for those kind of operations. No user should get access here, they will use the "customer" namespace as their entry point. 
* TBD: Currently the root namespace level policies and users for roles such as Vault operators, key operators, auditors, etc. are not being created yet. 

```

```
Inside the "customer" namespace

* Creates additional child namespaces, which are the ones to be used by the individual lines of business/projects/etc.
* Enables the userpass backend and creates multiple accounts which removes the need for having an AD or other IdP available. This is just for testing purposes.
* Creates a Vault admin policy, so that they can manage stuff inside the "customer" namespace as needed.
* Creates Entities and Entity Aliases in the Identity Secret Engine for the created accounts and associates the only the admin policy. No user has permission to do anything at this level yet.

```

```
Inside the "ns1" namespace

* Creates Vault Identity Groups for users and admins plus associates the polices for the respective namespace.
* This enables the "Vault Admins" created in the "customer" namespace, to act also as admin also inside the child namespaces.
* Creates a dummy kv mount and populates a secret.
* The "namespace_user" policy doesn't give the user much permissions yet, other than access to the dummy kv store. Here a customer would need to define, what a namespace user is allowed to do.

```

