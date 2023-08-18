# module "cloud_deploy" {
#     source = "terraform-google-modules/cloud-deploy/google"

#     pipeline_name                = "google-pipeline-helm-deploy-gke"
#     location                     = data.terraform_remote_state.gke.outputs.cluster-info.region
#     project                      = var.project_id
#     stage_targets = [{
#       target                            = "prod"
#       profiles                          = ["test"]
#       gke                               = data.terraform_remote_state.gke.outputs.cluster-info.id
#       gke_cluster_sa                    = data.terraform_remote_state.gke.outputs.service_account_gke
#       artifact_storage                  = null
#       require_approval                  = false
#       execution_configs_service_account = "deployment-test-1-google"
#       worker_pool                       = null
#       }]
#     cloud_trigger_sa = "cd-trigger-1"
# }


resource "google_deployment_manager_deployment" "deployment" {
  name = "helm-deployment"

  target {
    config {
      content = templatefile("./builds/helm-deploy/config.yml", {REPO = "stt", TAG = var.tag, PROJECT_ID = var.project_id})
    }
  }

}