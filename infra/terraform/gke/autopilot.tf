module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"
  version                    = "27.0.0"
  project_id                 = var.project_id
  name                       = "${local.cluster_info.region}-cluster"
  regional                   = true
  region                     = local.cluster_info.region
  zones                      = local.cluster_info.cluster_zones
  network                    = local.cluster_info.network
  subnetwork                 = local.cluster_info.subnet_name
  ip_range_pods              = local.cluster_info.pod_cidr_name
  ip_range_services          = local.cluster_info.svc_cidr_name
  horizontal_pod_autoscaling = true
  service_account = google_service_account.service_account_nodes.email
}

