locals {
  base_oauth_scope = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/compute",
  ]
}

resource "google_container_node_pool" "node_pool" {
  name               = var.name
  cluster            = var.gke_cluster_name
  location           = var.region
  version            = var.kubernetes_version
  #initial_node_count = var.initial_node_count
  node_count         = var.node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    image_type   = var.image_type 
    disk_size_gb = var.disk_size_in_gb
    machine_type = var.machine_type
    labels       = var.node_labels
    disk_type    = var.disk_type
    tags         = var.node_tags
    preemptible  = var.preemptible_nodes
    service_account = var.service_account_email
    shielded_instance_config {
      enable_secure_boot = var.enable_secure_boot
    }

    workload_metadata_config {
      mode = var.node_metadata
    }

    oauth_scopes = concat(local.base_oauth_scope, var.additional_oauth_scopes)
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  lifecycle {
    #create_before_destroy = true
    #ignore_changes = [ node_config ]
  }
}
