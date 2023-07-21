provider "aws" {
"AKIA3BE3TGG7Q5T3H3P6"
"4wQet1yAmsaB5r3VGHyXoKp2u79jfi+eB8yx1yRc"
}
terraform {
  backend "s3" {}
  required_providers {
    mongodbatlas = {
      version = "0.6.3"

      source = "mongodb/mongodbatlas"
    }

  }
}

provider "mongodbatlas" {
  public_key  = "jnsmlncg"
  private_key = "035571dc-fd02-42ef-a303-9c1ab5149ae9"
}
module "atlas_project" {
  source       = "./modules/project"
  project_name = var.atlas_project_name
  teams        = var.atlas_project_teams
}

module "atlas_network_access" {
  source               = "./modules/network_access"
  for_each             = { for key in var.atlas_network_container : key.atlas_region => key }
  atlas_project_id     = module.atlas_project.id
  atlas_region         = each.value.atlas_region
  atlas_cidr_block     = each.value.atlas_cidr_block
  whitelisted_networks = var.atlas_whitelist_cidrs
}

// todo: allow passing of name to the peering

module "atlas_vpc_peering" {
  source             = "./modules/vpc_peering"
  atlas_project_id   = module.atlas_project.id
  aws_region         = var.aws_main_region
  network_containers = values(module.atlas_network_access)
  vpc_id             = "vpc-006b219b3c51a17e0"
}

module "atlas_clusters" {
  source                      = "./modules/cluster"
  for_each                    = { for key in var.atlas_clusters : key.cluster_name => key }
  atlas_project_id            = module.atlas_project.id
  cluster_name                = each.value.cluster_name
  cluster_engine_version      = each.value.mongo_version
  atlas_regions               = each.value.atlas_regions
  provider_disk_iops          = each.value.provider_disk_iops
  provider_instance_size_name = each.value.provider_instance_size_name
  use_encryption_at_rest      = each.value.use_encryption_at_rest
  disk_size_gb                = each.value.disk_size
  depends_on                  = [module.atlas_network_access.network_container_id]
  atlas_replication_factor    = each.value.atlas_replication_factor

}

module "atlas_lab_database_user" {
  source               = "./modules/database_user"
  for_each             = { for key in var.atlas_db_users : key.env_name => key }
  atlas_project_id     = module.atlas_project.id
  username             = each.value.mongo_username
  password             = each.value.mongo_password
  database_name        = each.value.mongo_dbname
  readWriteAnyDatabase = each.value.readWriteAnyDatabase

}



/*
data "aws_secretsmanager_secret" "secrets" {
  name = "mondodb-master-passwd"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}
locals {
  secrets=jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["prod-db"]
}

#create a RDS Database Instance
module "rds" {
  
  for_each ={
    for key in var.db_group : key.db_name => key
  }
  source = "./modules/rds"
  db_name=each.value.db_name
  engine = each.value.engine
  identifier = each.value.identifier
  storage = each.value.storage
  user = "postgres"
  passwd = local.secrets
  #passwd = each.value.passwd


  
}
*/