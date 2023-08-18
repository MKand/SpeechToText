# # https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes
# module "gke" {
#   source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
#   project_id                 = var.project_id
#   name                       = "${local.cluster_info.region}-standard-cluster"
#   region                     = local.cluster_info.region
#   zones                      = local.cluster_info.cluster_zones
#   network                    = local.cluster_info.network
#   subnetwork                 = local.cluster_info.subnet_name
#   ip_range_pods              = local.cluster_info.pod_cidr_name
#   ip_range_services          = local.cluster_info.svc_cidr_name
#   horizontal_pod_autoscaling = true

#   node_pools = [
#     {
#       name                      = "default-node-pool"
#       machine_type              = "e2-medium"
#       node_locations            = "${local.region}-a,${local.region}-b,${local.region}-c"
#       min_count                 = 1
#       max_count                 = 4
#       disk_size_gb              = 10
#       disk_type                 = "pd-standard"
#       image_type                = "COS_CONTAINERD"
#       auto_repair               = true
#       auto_upgrade              = true
#       service_account           = google_service_account.service_account_nodes.email
#       initial_node_count        = 2
#     },
#   ]

#   node_pools_labels = {
#     all = {}

#     default-node-pool = {
#       default-node-pool = true
#     }
#   }

#   node_pools_tags = {
#     all = []

#     default-node-pool = [
#       "default-node-pool",
#     ]
#   }
# }