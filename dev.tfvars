/*db_group= [
    {
        db_name="payment_db"
        engine="mysql"
        identifier="myrdsinstance"
        storage="20"
        



    },
    {
        db_name="auth-db"
        engine="mysql"
        identifier="myrdsinstance"
        storage="20"
        
    },
    {
        db_name="gateway-db"
        engine="mysql"
        identifier="myrdsinstance"
        storage="20"
        

    }

]
*/
atlas_project_name = "demo"
atlas_project_teams=

atlas_whitelist_cidrs = [
  "172.18.84.0/24",
  "172.18.85.0/24",
  "172.18.86.0/24"
]

atlas_network_container = [
  {
    atlas_region     = "US_WEST_2"
    atlas_cidr_block = "10.8.0.0/21"
  }
]

atlas_clusters = [
  {
    cluster_name                = "demo-cluster"
    mongo_version               = "6.0"
    atlas_regions               = ["US_WEST_2"]
    provider_disk_iops          = 3000
    use_encryption_at_rest      = "true"
    disk_size                   = 10
    provider_instance_size_name = "M10"
    atlas_replication_factor    = 3
  }
]

atlas_db_users = [
  {
    env_name             = "demo",
    mongo_username       = "demo"
    mongo_password       = "ixQi7t2VpZ7lHQA2Ay"
    mongo_dbname         = "demo_db"
    readWriteAnyDatabase = true
  }

