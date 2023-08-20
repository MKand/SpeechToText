
data "google_compute_default_service_account" "default" {
  project = var.project_id
}

# module "cloud_deploy" {
#     source = "terraform-google-modules/cloud-deploy/google"
#     pipeline_name                = "google-pipeline-helm-deploy-gke"
#     location                     = data.terraform_remote_state.gke.outputs.cluster-info.region
#     project                      = var.project_id
#     stage_targets = [{
#       target                            = "prod"
#       profiles                          = []
#       gke                               = data.terraform_remote_state.gke.outputs.cluster-info.id
#       gke_cluster_sa                    = [data.google_compute_default_service_account.default.email]
#       artifact_storage                  = null
#       require_approval                  = false
#       execution_configs_service_account = "deployment-test-1-google"
#       worker_pool                       = null
#       }]
#     # cloud_trigger_sa = "cd-trigger-1"
# }

resource "google_clouddeploy_target" "primary" {
  location = "europe-west4"
  name     = "gke-deployment"

  description = "basic description"

  gke {
    cluster = data.terraform_remote_state.gke.outputs.cluster-info.id
  }
  project          = var.project_id
  require_approval = false
}


