resource "mongodbatlas_network_container" "test" {
  project_id       = var.atlas_project_id
  atlas_cidr_block = var.atlas_cidr_block
  provider_name    = "AWS"
  region_name      = var.atlas_region
}

// this insane duplication is because terraform fails for some reason when it tries to create mongodbatlas_project_ip_whitelist with count greater than 1
// TODO check if it can be refactored
resource "mongodbatlas_project_ip_whitelist" "whitelist0" {
  project_id = var.atlas_project_id
  count      = length(var.whitelisted_networks) > 0 ? 1 : 0
  cidr_block = element(var.whitelisted_networks, 0)
}

resource "mongodbatlas_project_ip_whitelist" "whitelist1" {
  project_id = var.atlas_project_id
  count      = length(var.whitelisted_networks) > 1 ? 1 : 0
  cidr_block = element(var.whitelisted_networks, 1)
}

resource "mongodbatlas_project_ip_whitelist" "whitelist2" {
  project_id = var.atlas_project_id
  count      = length(var.whitelisted_networks) > 2 ? 1 : 0
  cidr_block = element(var.whitelisted_networks, 2)
}

resource "mongodbatlas_project_ip_whitelist" "whitelist3" {
  project_id = var.atlas_project_id
  count      = length(var.whitelisted_networks) > 3 ? 1 : 0
  cidr_block = element(var.whitelisted_networks, 3)
}

resource "mongodbatlas_project_ip_whitelist" "whitelist4" {
  project_id = var.atlas_project_id
  count      = length(var.whitelisted_networks) > 4 ? 1 : 0
  cidr_block = element(var.whitelisted_networks, 4)
}