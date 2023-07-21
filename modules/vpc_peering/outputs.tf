output "peering_connection_ids" {
  value = mongodbatlas_network_peering.test.*.connection_id
}

output "peering_connections" {
  value = mongodbatlas_network_peering.test.*
}

output "container_id_to_pcx_id" {
  value = zipmap(
    mongodbatlas_network_peering.test.*.container_id,
    mongodbatlas_network_peering.test.*.connection_id
  )
}