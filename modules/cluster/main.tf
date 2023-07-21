terraform {
  required_version = ">= 0.13.5"
}

resource "mongodbatlas_cluster" "cluster" {
  count = length(var.atlas_regions) == 1 ? 1 : 0

  project_id                  = var.atlas_project_id
  name                        = var.cluster_name
  num_shards                  = 1
  replication_factor          = var.atlas_replication_factor
  mongo_db_major_version      = var.cluster_engine_version
  provider_name               = "AWS"
  provider_encrypt_ebs_volume = true
  provider_instance_size_name = var.provider_instance_size_name
  provider_region_name        = var.atlas_regions[0]
  disk_size_gb                = var.disk_size_gb       // min value
  provider_disk_iops          = var.provider_disk_iops // min value
  encryption_at_rest_provider = var.use_encryption_at_rest == "true" ? "AWS" : "NONE"
  provider_backup_enabled     = true
  auto_scaling_compute_enabled = var.auto_scaling_compute_enabled

  // TODO impossible to set point in time restore to ON for now (https://discuss.hashicorp.com/t/question-about-mongodbatlas-provider/5088)
  // set it manuallly in the settings
}

resource "mongodbatlas_cluster" "dr_cluster" {
  count = length(var.atlas_regions) == 2 ? 1 : 0

  project_id                  = var.atlas_project_id
  name                        = var.cluster_name
  cluster_type                = "REPLICASET"
  num_shards                  = 1
  mongo_db_major_version      = var.cluster_engine_version
  provider_name               = "AWS"
  provider_encrypt_ebs_volume = true
  provider_instance_size_name = var.provider_instance_size_name
  disk_size_gb                = var.disk_size_gb       // min value
  provider_disk_iops          = var.provider_disk_iops // min value
  encryption_at_rest_provider = var.use_encryption_at_rest == "true" ? "AWS" : "NONE"
  provider_backup_enabled     = true
  auto_scaling_compute_enabled = var.auto_scaling_compute_enabled

  // TODO impossible to set point in time restore to ON for now (https://discuss.hashicorp.com/t/question-about-mongodbatlas-provider/5088)
  // set it manuallly in the settings
  // https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster#replication_specs
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.atlas_regions[0]
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
    regions_config {
      region_name     = var.atlas_regions[1]
      electable_nodes = 2
      priority        = 6
      read_only_nodes = 0
    }
  }
}

resource "mongodbatlas_cluster" "dr_cluster_multi_region" {
  count = length(var.atlas_regions) == 3 ? 1 : 0

  project_id                  = var.atlas_project_id
  name                        = var.cluster_name
  num_shards                  = 1
  mongo_db_major_version      = var.cluster_engine_version
  provider_name               = "AWS"
  provider_encrypt_ebs_volume = true
  provider_instance_size_name = var.provider_instance_size_name
  disk_size_gb                = var.disk_size_gb       // min value
  provider_disk_iops          = var.provider_disk_iops // min value
  encryption_at_rest_provider = var.use_encryption_at_rest == "true" ? "AWS" : "NONE"
  provider_backup_enabled     = true
  auto_scaling_compute_enabled = var.auto_scaling_compute_enabled

  // TODO impossible to set point in time restore to ON for now (https://discuss.hashicorp.com/t/question-about-mongodbatlas-provider/5088)
  // set it manuallly in the settings
  // https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster#replication_specs
  replication_specs {
    zone_name  = "Zone 1"
    num_shards = 1
    regions_config {
      region_name     = var.atlas_regions[0]
      electable_nodes = 2
      priority        = 7
      read_only_nodes = 0
    }
    regions_config {
      region_name     = var.atlas_regions[1]
      electable_nodes = 2
      priority        = 6
      read_only_nodes = 0
    }
    regions_config {
      region_name     = var.atlas_regions[2]
      electable_nodes = 1
      priority        = 5
      read_only_nodes = 0
    }
  }
}

resource "mongodbatlas_cloud_provider_snapshot_backup_policy" "atlas_dev1_cluster_daily_backup_policy" {
  count        = var.cluster_name == "non-prod-dev1-cluster" ? 1 : 0
  cluster_name = data.mongodbatlas_cluster.dev1_cluster.name
  project_id   = data.mongodbatlas_cluster.dev1_cluster.project_id

  // Number of days back in time you can restore to with point-in-time accuracy. Must be a positive, non-zero integer.
  // Default value is 7. Documentation it is optional, but it is not.
  restore_window_days = 7
  // Specify true to apply the retention changes in the updated backup policy to snapshots that Atlas took previously
  update_snapshots = false

  policies {
    id = mongodbatlas_cluster.cluster[count.index].snapshot_backup_policy.0.policies.0.id
    policy_item {
      frequency_interval = 6
      frequency_type     = "hourly"
      id                 = mongodbatlas_cluster.cluster[count.index].snapshot_backup_policy.0.policies.0.policy_item.0.id
      retention_unit     = "days"
      retention_value    = 2
    }
    policy_item {
      frequency_interval = 1
      frequency_type     = "daily"
      id                 = mongodbatlas_cluster.cluster[count.index].snapshot_backup_policy.0.policies.0.policy_item.1.id
      retention_unit     = "days"
      retention_value    = 35
    }
    policy_item {
      frequency_interval = 6
      frequency_type     = "weekly"
      id                 = mongodbatlas_cluster.cluster[count.index].snapshot_backup_policy.0.policies.0.policy_item.2.id
      retention_unit     = "weeks"
      retention_value    = 5
    }
    policy_item {
      frequency_interval = 40
      frequency_type     = "monthly"
      id                 = mongodbatlas_cluster.cluster[count.index].snapshot_backup_policy.0.policies.0.policy_item.3.id
      retention_unit     = "months"
      retention_value    = 12
    }
  }
}

data "mongodbatlas_cluster" "dev1_cluster" {
  name       = var.cluster_name
  project_id = var.atlas_project_id
}
