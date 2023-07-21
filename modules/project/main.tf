resource "mongodbatlas_project" "atlas_project" {
  name   = var.project_name
  org_id = var.org_id
  dynamic "teams" {
    for_each = var.teams
    content {
      team_id    = teams.value["team_id"]
      role_names = teams.value["role_names"]
    }
  }
}