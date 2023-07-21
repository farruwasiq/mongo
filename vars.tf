/*variable "db_group" {
  default = []
}
*/
variable "atlas_db_users" {
  default = []

}
variable "atlas_project_name" {


}
variable "atlas_project_teams" {
  default = []

}
variable "atlas_whitelist_cidrs" {
  type = list(string)

}
variable "atlas_clusters" {
  type = list(object({
    cluster_name                = string
    mongo_version               = string
    atlas_region                = list(string)
    provider_disk_iops          = number
    use_encryption_at_rest      = string
    disk_size                   = number
    provider_instance_size_name = string
    atlas_replication_factor    = number
  }))


}
variable "atlas_network_container" {
  type = list(object({
    atlas_region     = string
    atlas_cidr_block = string
  }))

}
variable "aws_main_region" {
  default = "us-east-1"

}