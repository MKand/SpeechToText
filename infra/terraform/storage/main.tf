resource "google_firestore_database" "database" {
  project                     = var.project_id
  name                        = "(default)"
  location_id                 = "eur3"
  type                        = "DATASTORE_MODE"
  concurrency_mode            = "OPTIMISTIC"
  app_engine_integration_mode = "DISABLED"
}

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = "europe-west4"
  repository_id = "stt"
  description   = "docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}