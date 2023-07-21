output "network_container_id" {
  value = mongodbatlas_network_container.test.container_id
}

output "atlas_cidr_block" {
  value = mongodbatlas_network_container.test.atlas_cidr_block
}