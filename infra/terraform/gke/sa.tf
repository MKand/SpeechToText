resource "google_service_account" "service_account_nodes" {
  project = var.project_id
  account_id   = "nodes-sa"
  display_name = "Service Account"
}

resource "google_project_iam_binding" "artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${google_service_account.service_account_nodes.email}",
  ]
}

resource "google_project_iam_binding" "monitoring_metricwriter" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.service_account_nodes.email}",
  ]
}

resource "google_project_iam_binding" "monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  members = [
    "serviceAccount:${google_service_account.service_account_nodes.email}",
  ]
}

resource "google_project_iam_binding" "logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.service_account_nodes.email}",
  ]
}


resource "google_project_iam_binding" "stackdriver" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  members = [
    "serviceAccount:${google_service_account.service_account_nodes.email}",
  ]
}


