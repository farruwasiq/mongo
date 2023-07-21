# For VPC peerings ensure DNS and Hostname resolution are both enabled for VPC peerings are enabled

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "mongodbatlas_network_peering" "test" {
  count = length(var.network_containers)

  accepter_region_name   = var.aws_region
  project_id             = var.atlas_project_id
  container_id           = var.network_containers[count.index].network_container_id
  provider_name          = "AWS"
  route_table_cidr_block = data.aws_vpc.vpc.cidr_block
  vpc_id                 = var.vpc_id
  aws_account_id         = data.aws_vpc.vpc.owner_id //var.vpc_owner_account_id
}

# the following assumes an AWS provider is configured
resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = length(var.network_containers)
  vpc_peering_connection_id = mongodbatlas_network_peering.test[count.index].connection_id
  auto_accept               = true
  tags                      = var.tags
}

resource "mongodbatlas_network_peering" "analytics" {
  count = length(var.analytics) == 5 ? 1 : 0

  accepter_region_name   = var.analytics["region"]
  project_id             = var.atlas_project_id
  container_id           = var.network_containers[var.analytics["container"]].network_container_id
  provider_name          = "AWS"
  route_table_cidr_block = var.analytics["cidr"]
  vpc_id                 = var.analytics["vpc"]
  aws_account_id         = var.analytics["account"]
}