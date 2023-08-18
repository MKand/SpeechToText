module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
#   version = 
  project_id                  = var.project_id
  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "servicemanagement.googleapis.com",
    "artifactregistry.googleapis.com",
    "gkehub.googleapis.com",
    "clouddeploy.googleapis.com",
    "speech.googleapis.com",
    "firestore.googleapis.com"
  ]
}