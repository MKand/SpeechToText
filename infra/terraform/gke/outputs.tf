output "cluster-info" {
  value = {
      name   = module.gke.name
      id     = module.gke.cluster_id
      region = module.gke.region
      zones  = module.gke.zones
    }
}

output "cluster-endpoint" {
  value = module.gke.endpoint
  sensitive = true
}

output "cluster-certificate" {
  value = module.gke.ca_certificate
  sensitive = true
}

output "service_account_gke" {
  value = module.gke.service_account
  description = "GKE service account name"
}


