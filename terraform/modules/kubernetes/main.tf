//resource "google_service_account" "default" {
//  account_id   = "service-account-id"
//  display_name = "Service Account"
//}

resource "google_container_cluster" "primary" {
  name     = var.kube_cluster_name
  location = var.region
  network = var.network
  min_master_version = var.master_version
  node_version = var.master_version
  enable_legacy_abac = true

  //Stackdriver Logging - Отключен
  //Stackdriver Monitoring - Отключен
  //Устаревшие права доступа - Включено


  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = var.kube_node_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count


//   enable_legacy_abac
//    node_version =

  node_config {

    image_type   = var.node_image_type
    machine_type = var.machine_type
    disk_size_gb = var.node_disk_size_gb
//    preemptible  = false


//    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
//    service_account_id      = var.service_account_key_id  # todo
//    node_service_account_id = var.service_account_key_id  # todo

//    service_account = google_service_account.default.email
//    oauth_scopes    = [
//      "https://www.googleapis.com/auth/cloud-platform"
//    ]
//    labels = {
//      foo = "bar"
//    }
    # Tags can used to identify targets in firewall rules
    tags = [var.k8s-network-tag, "nodes"]
  }
}
