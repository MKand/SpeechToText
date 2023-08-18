variable "project_id" {
  description = "Project ID"
}

variable "network_name" {
  description = "VPC name"
  default = "app-vpc"
}

variable "gke-network" {
  description = "Networking config for the cluster"
  type = object({
    region       = string
    subnet = object({
      name = string
      cidr = string
    })
  })
  default = {
      region = "europe-west4"
      subnet = {
        name = "europe-west4"
        cidr = "10.1.0.0/17"
      }
    }
}

