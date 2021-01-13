terraform {
  # Версия terraform
  required_version = "0.12.29"
}

provider "google" {
  # Версия провайдера
  version = "2.15.0"
  project = var.project
  region  = var.region
}

module "vpc" {
  source           = "../modules/vpc"
}

module "firewall_ssh" {
  source      = "../modules/firewall"
  fw_name        = var.fw_name
  fw_network     = var.network
  fw_priority  = var.fw_priority
  fw_protocol    = var.fw_protocol
  fw_ports       = var.fw_ports
  fw_source_ranges = var.fw_source_ranges
  fw_target_tags   = var.k8s-network-tag
  fw_source_tags   = var.fw_source_tags
}


module "kubernetes" {
  source = "../modules/kubernetes"
  kube_cluster_name = var.kube_cluster_name
  kube_node_pool_name = var.kube_node_pool_name
  machine_type = var.machine_type
  region = var.region
  node_count = var.node_count
  node_disk_size_gb = var.node_disk_size_gb
  node_image_type = var.node_image_type
  network = var.network
  master_version = var.master_version
  k8s-network-tag = var.k8s-network-tag
}

