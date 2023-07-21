resource "mongodbatlas_database_user" "user" {
  count = var.readWriteAnyDatabase ? 0 : 1 //TODO temporary workaround. For phase 1, ci2_user should have permission to read/write to any database

  username           = var.username
  password           = var.password
  project_id         = var.atlas_project_id
  auth_database_name = "admin"

  roles {
    role_name     = "dbAdmin"
    database_name = var.database_name
  }
}

resource "mongodbatlas_database_user" "user_readWriteAnyDatabase" {
  count = var.readWriteAnyDatabase ? 1 : 0 //TODO temporary workaround. For phase 1, ci2_user should have permission to read/write to any database

  username           = var.username
  password           = var.password
  project_id         = var.atlas_project_id
  auth_database_name = "admin"

  roles {
    role_name     = "dbAdmin"
    database_name = var.database_name
  }

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}