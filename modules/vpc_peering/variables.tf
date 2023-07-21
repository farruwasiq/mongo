variable "atlas_project_id" {}
variable "aws_region" {}
//TODO: Not needed, kept for backwards compatability
variable "atlas_region" { default = "" }
variable "network_containers" {}
variable "vpc_id" {}
variable "tags" {}
variable "analytics" { default = {} }