resource "google_compute_network" "cluster_network" {
  name                    = "cluster-network"
  auto_create_subnetworks = "true"
}
