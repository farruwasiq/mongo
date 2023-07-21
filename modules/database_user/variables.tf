variable "atlas_project_id" {}
variable "username" {}
variable "password" {}
variable "database_name" {}
variable "readWriteAnyDatabase" { default = false } //TODO temporary workaround. For phase 1, ci2_user should have permission to read/write to any database