module "stt-proxy-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  location            = data.terraform_remote_state.gke.outputs.cluster-info.region
  cluster_name        = data.terraform_remote_state.gke.outputs.cluster-info.name
  name = "stt-proxy"
  project_id          = var.project_id
  roles               = ["roles/datastore.user", "roles/speech.client"]
  namespace           = kubernetes_service_account.stt-proxy.metadata[0].namespace
  use_existing_k8s_sa = true
  k8s_sa_name         = kubernetes_service_account.stt-proxy.metadata[0].name
}