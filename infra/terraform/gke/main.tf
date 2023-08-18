locals {
  region = data.terraform_remote_state.vpc.outputs.cluster_network_info.region # pulled apart for readability
  cluster_info = {
        region        = local.region
        subnet_name   = data.terraform_remote_state.vpc.outputs.cluster_network_info.subnet.name
        cluster_zones  = ["${local.region}-a", "${local.region}-b", "${local.region}-c"]
        pod_cidr_name = "${local.region}-pod-cidr"
        svc_cidr_name = "${local.region}-svc-cidr"
        network       = data.terraform_remote_state.vpc.outputs.network.network_name
      }
}



