variable region {
  description = "Region"
}

variable kube_cluster_name {
  description = "Cluster name"
}

variable kube_node_pool_name {
  description = "Node pool name"
}

variable machine_type {
  description = "Machine_type"
}

variable node_count {
  description = "Nodes count"
}

variable node_disk_size_gb {
  description = "Node disk size in Gb"
}

variable "node_image_type" {
  description = "The image type to use for nodes."
}

variable "network" {
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected"
}

variable "master_version" {
  description = "Cluster version"
}

variable "k8s-network-tag" {
  description = "k8s cluster network tag"
}






