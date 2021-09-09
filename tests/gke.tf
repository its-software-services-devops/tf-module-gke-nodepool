##### NOT YET TEST HERE ####

locals {
  project = "its-artifact-commons"
  region = "us-west1"

  cluster_name = "yru-openedx-prod-1"
  network_name = "team-a-vpc-network"
  kubernetes_version = "1.20.9-gke.700"
  nodes_subnetwork_name = "team-a-vpc-network"
  pods_secondary_ip_range_name = ""
  services_secondary_ip_range_name = ""
  master_ipv4_cidr_block = "10.128.254.0/28"
}

#### Service Account ####
resource "google_service_account" "yru-openedx-prod-sa" {
  account_id   = "yru-openedx-prod"
  display_name = "Service Account for ETDA"
}

#### Cluster ####
module "yru-openedx-prod-cluster" {
  source = "./modules/gke-cluster"

  name                             = local.cluster_name
  region                           = local.region
  #project                          = local.project
  kubernetes_version               = local.kubernetes_version
  network_name                     = local.network_name
  nodes_subnetwork_name            = local.nodes_subnetwork_name
  pods_secondary_ip_range_name     = local.pods_secondary_ip_range_name
  services_secondary_ip_range_name = local.services_secondary_ip_range_name
  enable_shielded_nodes            = true

  # private cluster options
  enable_private_endpoint = false
  enable_private_nodes    = true
  master_ipv4_cidr_block  = local.master_ipv4_cidr_block

  master_authorized_network_cidrs = [
    {
      # This is the module default, but demonstrates specifying this input.
      cidr_block   = "0.0.0.0/0"
      display_name = "from the Internet"
    },
  ]
}

#### Pools ####

module "yru-openedx-prod-basic-pool" {
  source = "./modules/node-pool"

  name             = "yru-openedx-prod-basic-pool"
  region           = "us-west1"
  gke_cluster_name = module.yru-openedx-prod-cluster.name
  machine_type     = "n1-standard-2"
  min_node_count   = "1"
  max_node_count   = "2"
  node_count       = "1"
  service_account_email = google_service_account.yru-openedx-prod-sa.email

  # Match the Kubernetes version from the GKE cluster!
  kubernetes_version = local.kubernetes_version
}
