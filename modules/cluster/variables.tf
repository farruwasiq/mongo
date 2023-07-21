variable "atlas_project_id" {}
variable "cluster_name" {}
variable "cluster_engine_version" {}
variable "provider_disk_iops" { default = 100 }
variable "provider_instance_size_name" { default = "M10" }
variable "atlas_regions" {}
variable "use_encryption_at_rest" {}
variable "disk_size_gb" { default = 10 }
variable "auto_scaling_compute_enabled" { default = false }
variable "atlas_replication_factor" {}