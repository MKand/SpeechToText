
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.gke.outputs.cluster-endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.gke.outputs.cluster-certificate)
}

resource "kubernetes_namespace" "ns" {
  metadata {
    annotations = {
      name = "stt"
    }

    labels = {
      namespace = "stt"
    }

    name = "stt"
  }
}

resource "kubernetes_service_account" "stt-proxy" {
  metadata {
    name      = "stt-proxy"
    namespace = "stt"
    annotations = {
      "iam.gke.io/gcp-service-account"="stt-proxy@${var.project_id}.iam.gserviceaccount.com"
    }
  }

}