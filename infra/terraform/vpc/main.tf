locals {
  primary_subnets =  [{
      subnet_name   = var.gke-network.subnet.name
      subnet_ip     = cidrsubnet(var.gke-network.subnet.cidr, 2, 2)
      subnet_region = var.gke-network.region
    }]

  secondary_subnets = {
    "${var.gke-network.subnet.name}" = [
        {
            range_name    = "${var.gke-network.subnet.name}-private-ipv4cidr"
            ip_cidr_range = cidrsubnet(var.gke-network.subnet.cidr, 11, 1 + 2000)
        },
        {
            range_name    = "${var.gke-network.subnet.name}-svc-cidr"
            ip_cidr_range = cidrsubnet(var.gke-network.subnet.cidr, 7, 1 + 96)
        },
        {
          range_name    = "${var.gke-network.subnet.name}-pod-cidr"
          ip_cidr_range = cidrsubnet(var.gke-network.subnet.cidr, 4, 3)
        }
    ]}
  }

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version = "7.2.0"
  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"
  subnets = local.primary_subnets
  secondary_ranges = local.secondary_subnets
}


