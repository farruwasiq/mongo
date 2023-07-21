variable "atlas_project_id" {}
variable "atlas_region" {}
variable "whitelisted_networks" { type = list(string) }
variable "atlas_cidr_block" { default = "10.8.0.0/21" }