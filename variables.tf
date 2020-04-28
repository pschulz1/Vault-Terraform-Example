variable "vault" {
  default = "http://127.0.0.1:8200"
}

variable "token" {
  default = "root"
}

variable "namespaces" {
  type = list(string)
  default = [
    "ns1",
    "ns2",
    "ns3",
    "ns4"
  ]
}

variable "admin" {
  type = map
  default = {
    peter = "Peter Pan",
    moby  = "Moby Dick"
    bob   = "Bob Bobster"
    alice = "Alice Wonderland"
  }
}

variable "user" {
  type = map
  default = {
    tim     = "Tim Arenz",
    patrick = "Patrick Schulz",
    joern   = "Joern Stenkamp",
    kapil   = "Kapil Arora"
  }
}
